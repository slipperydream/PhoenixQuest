extends Control

signal textbox_closed
enum BarType {HEALTH, ENERGY}

@export var enemy : Resource = null
@export var party : Array[Resource] = [null, null, null]
var current_party_health = [0, 0, 0]
var players = []
var current_enemy_health = 0
var is_defending = false
var targeted_player = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_party_display()
	set_enemy_display()
	
	$TextboxMarginContainer/Textbox.hide()
	$ActionsMarginContainer.hide()
	
	display_text("A wild %s appears!" % enemy.name.to_upper())
	await self.textbox_closed
	$ActionsMarginContainer.show()

func set_party_display():
	for n in party.size():
		current_party_health[n] = party[n].current_health
	
	players.append($PartyPanel/PartyMemberContainer1.get_node("MarginContainer/PartyMemberData/GridContainer/HPContainer"))
	players.append($PartyPanel/PartyMemberContainer2.get_node("MarginContainer/PartyMemberData/GridContainer/HPContainer"))
	players.append($PartyPanel/PartyMemberContainer3.get_node("MarginContainer/PartyMemberData/GridContainer/HPContainer"))

	for n in party.size():
		set_bar(players[n], BarType.HEALTH, current_party_health[n], party[n].max_health)	
		#set_bar(players[n], BarType.ENERGY, current_party_health[n], party[n].max_health)
	$PartyPanel/PartyMemberContainer1.get_node("MarginContainer/PartyMemberData/GridContainer/Name").text = party[0].name
	$PartyPanel/PartyMemberContainer2.get_node("MarginContainer/PartyMemberData/GridContainer/Name").text = party[1].name
	$PartyPanel/PartyMemberContainer3.get_node("MarginContainer/PartyMemberData/GridContainer/Name").text = party[2].name
	
	$PartyPanel/PartyMemberContainer1.get_node("MarginContainer/PartyMemberData/Portrait").texture = party[0].portrait	
	$PartyPanel/PartyMemberContainer2.get_node("MarginContainer/PartyMemberData/Portrait").texture = party[1].portrait
	$PartyPanel/PartyMemberContainer3.get_node("MarginContainer/PartyMemberData/Portrait").texture = party[2].portrait

func set_enemy_display():
	current_enemy_health = enemy.health	
	set_bar($EnemyContainer, BarType.HEALTH, current_enemy_health, enemy.health)
	$EnemyContainer/Enemy.texture = enemy.texture
		
func set_bar(player_data, type, current, maximum):
	if type == BarType.HEALTH:
		player_data.get_node("HealthBar").value = current
		player_data.get_node("HealthBar").max_value = maximum
		player_data.get_node("HP").text = "HP: %d" % [current]
	elif type == BarType.ENERGY:
		player_data.get_node("EnergyBar").value = current
		player_data.get_node("EnergyBar").max_value = maximum
		player_data.get_node("Energy").text = "EN: %d" % [current]
	
func _input(event):
	if $TextboxMarginContainer/Textbox.visible and (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		$TextboxMarginContainer/Textbox.hide()
		emit_signal("textbox_closed")
	
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func display_text(text):
	$TextboxMarginContainer/Textbox.show()
	$TextboxMarginContainer/Textbox/BattleText.text = text
	
func enemy_turn():
	display_text("%s attacks you!" % enemy.name)
	await self.textbox_closed
	
	if is_defending:
		is_defending = false
		$AnimationPlayer.play("small_shake")
		await $AnimationPlayer.animation_finished
		display_text("You block the attack!")
		await self.textbox_closed
	else:	
		current_party_health[targeted_player] = max(0, current_party_health[targeted_player] - enemy.attack_damage)
		set_bar(players[targeted_player], BarType.HEALTH, current_party_health[targeted_player], party[targeted_player].max_health)
		
		$AnimationPlayer.play("screen_shake")
		await $AnimationPlayer.animation_finished
		display_text("%s dealt you %d damage!" % [enemy.name, enemy.attack_damage])

func _on_run_pressed():
	display_text("Got away safely!")
	await self.textbox_closed
	
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()


func _on_attack_pressed():
	display_text("You swing valiantly at %s!" % enemy.name)
	await self.textbox_closed
	
	var num = randi_range(0, party.size()-1)
	current_enemy_health = max(0, current_enemy_health - party[num].attack_damage)
	set_bar($EnemyContainer, BarType.HEALTH, current_enemy_health, enemy.health)
	
	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished
	display_text("You dealt %d damage!" % party[num].attack_damage)
	
	if current_enemy_health == 0:
		display_text("%s is defeated!" % enemy.name)
		await self.textbox_closed
		
		$AnimationPlayer.play("enemy_death")
		await $AnimationPlayer.animation_finished
		await get_tree().create_timer(0.25).timeout
		get_tree().quit()
	else:
		enemy_turn()

func _on_defend_pressed():
	is_defending = true
	display_text("You prepare your defense!")
	await self.textbox_closed

	await get_tree().create_timer(0.25).timeout
	enemy_turn()
