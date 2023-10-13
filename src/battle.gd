extends Control

signal textbox_closed
enum BarType {HEALTH, ENERGY}

var enemy : Combatant = null
var party : Array[Combatant] = []
var party_hp_bars = []

@onready var turn_queue : TurnQueue = $TurnQueue
var is_defending = false
var targeted_player = 0
var turns : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	turn_queue.initialize()
	
	var pcs = turn_queue.get_children()
	for x in pcs:
		if x.is_party_member:
			party.append(x)
			print("Added %s to party" % x.char_name)
		else:
			enemy = x
			print("%s is the enemy" % x.char_name)
	set_party_display()
	set_enemy_display()
	
	$TextboxMarginContainer/Textbox.hide()
	$ActionsBottomContainer.hide()
	
	if enemy:
		display_text("A wild %s appears!" % enemy.char_name)
	await self.textbox_closed
	$ActionsBottomContainer.show()
	for x in $ActionsBottomContainer.get_tree().get_nodes_in_group("combat"):
		x.show()
		
	play_turn()

func set_party_display():	
	party_hp_bars.append($PartyPanel/PartyMemberContainer1.get_node("MarginContainer/PartyMemberData/GridContainer/HPContainer"))
	party_hp_bars.append($PartyPanel/PartyMemberContainer2.get_node("MarginContainer/PartyMemberData/GridContainer/HPContainer"))
	party_hp_bars.append($PartyPanel/PartyMemberContainer3.get_node("MarginContainer/PartyMemberData/GridContainer/HPContainer"))

	for n in party.size():
		set_bar(party_hp_bars[n], BarType.HEALTH, party[n].current_health, party[n].max_health)	
		#set_bar(players[n], BarType.ENERGY, current_party_health[n], party[n].max_health)
	$PartyPanel/PartyMemberContainer1.get_node("MarginContainer/PartyMemberData/GridContainer/Name").text = party[0].char_name
	$PartyPanel/PartyMemberContainer2.get_node("MarginContainer/PartyMemberData/GridContainer/Name").text = party[1].char_name
	$PartyPanel/PartyMemberContainer3.get_node("MarginContainer/PartyMemberData/GridContainer/Name").text = party[2].char_name
	
	# Draw characters on screen
	$PartyMember1.texture = party[0].texture
	$PartyMember1.set_flip_h(true)
	$PartyMember2.texture = party[1].texture
	$PartyMember3.texture = party[2].texture
	
	# Portraits
	$PartyPanel/PartyMemberContainer1.get_node("MarginContainer/PartyMemberData/Portrait").texture = party[0].portrait	
	$PartyPanel/PartyMemberContainer2.get_node("MarginContainer/PartyMemberData/Portrait").texture = party[1].portrait
	$PartyPanel/PartyMemberContainer3.get_node("MarginContainer/PartyMemberData/Portrait").texture = party[2].portrait

func set_enemy_display():
	set_bar($EnemyContainer, BarType.HEALTH, enemy.current_health, enemy.current_health)
	$EnemyContainer/EnemySprite.texture = enemy.texture
		
func set_bar(character_data, type, current, maximum):
	if type == BarType.HEALTH:
		character_data.get_node("HealthBar").value = current
		character_data.get_node("HealthBar").max_value = maximum
		character_data.get_node("HP").text = "HP: %d" % [current]
	elif type == BarType.ENERGY:
		character_data.get_node("EnergyBar").value = current
		character_data.get_node("EnergyBar").max_value = maximum
		character_data.get_node("Energy").text = "EN: %d" % [current]
	
func _input(event):
	if $TextboxMarginContainer/Textbox.visible and (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)):
		$TextboxMarginContainer/Textbox.hide()
		emit_signal("textbox_closed")
		
	$PartyMember1/ActionsCharacterContainer.hide()
	$PartyMember2/ActionsCharacterContainer.hide()
	$PartyMember3/ActionsCharacterContainer.hide()
	
	if Input.is_action_just_pressed("attack"):
		attack(0)
	elif Input.is_action_just_pressed("run_away"):
		run()
			
func display_text(text):
	$TextboxMarginContainer/Textbox.show()
	$TextboxMarginContainer/Textbox/BattleText.text = text
	

func get_active_combatant():
	return turn_queue.active_combatant
		
func play_turn():
	var combatant : Combatant = get_active_combatant()
	var targets : Array = get_targets()
	if not targets:
		battle_over()
		return
	var target : Combatant
	if combatant.is_party_member:
		# TODO add user selection of target
		target = targets[randi() % targets.size()]
	else:
		target = targets[randi() % targets.size()]
		
	await turn_queue.play_turn(target)
	if turns < 5:
		turns += 1
		play_turn()
	
func enemy_turn():
	await self.textbox_closed
	
	if is_defending:
		is_defending = false
		$AnimationPlayer.play("small_shake")
		await $AnimationPlayer.animation_finished
		#display_text("You block the attack!")
		await self.textbox_closed
	else:	
		party[targeted_player].current_health = max(0, party[targeted_player].current_health - enemy.attack_damage)
		set_bar(party_hp_bars[targeted_player], BarType.HEALTH, party[targeted_player].current_health, party[targeted_player].max_health)
		
		$AnimationPlayer.play("screen_shake")
		await $AnimationPlayer.animation_finished
		#display_text("%s dealt you %d damage!" % [enemy.name, enemy.attack_damage])
		

func run():
	display_text("Got away safely!")
	await self.textbox_closed
	for x in $ActionsBottomContainer.get_tree().get_nodes_in_group("combat"):
		x.hide()
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()


func attack(player):
	
	set_bar($EnemyContainer, BarType.HEALTH, enemy.current_health, enemy.max_health)
	

func _on_defend_pressed():
	is_defending = true
	display_text("You prepare your defense!")
	await self.textbox_closed
	
func battle_over():
	display_text("Battle is over, choom!")
	await self.textbox_closed
	get_tree().quit()
	
func get_targets():
	if get_active_combatant().is_party_member:
		return turn_queue.get_opponents()
	else:
		return turn_queue.get_party()
