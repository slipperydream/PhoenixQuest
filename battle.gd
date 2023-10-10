extends Control

signal textbox_closed
enum BarType {HEALTH, ENERGY}

@export var enemy : Resource = null
var current_player_health = 0
var current_enemy_health = 0
var is_defending = false

# Called when the node enters the scene tree for the first time.
func _ready():
	current_player_health = State.current_health
	current_enemy_health = enemy.health
	set_bar($PCPanel/PanelContainer/PCData/PCHealthBar, BarType.HEALTH, current_player_health, State.max_health)
	set_bar($EnemyContainer/EnemyHealthBar, BarType.HEALTH, current_enemy_health, enemy.health)
	$EnemyContainer/Enemy.texture = enemy.texture
	$TextboxMarginContainer/Textbox.hide()
	$ActionsMarginContainer/ActionPanel.hide()
	
	display_text("A wild %s appears!" % enemy.name.to_upper())
	await self.textbox_closed
	$ActionsMarginContainer/ActionPanel.show()

func set_bar(progress_bar, type, current, max):
	progress_bar.value = current
	progress_bar.max_value = max
	if type == BarType.HEALTH:
		progress_bar.get_node("Label").text = "HP: %d/%d" % [current, max]
	elif type == BarType.ENERGY:
		progress_bar.get_node("Label").text = "EN: %d/%d" % [current, max]
	
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
		current_player_health = max(0, current_player_health - enemy.attack_damage)
		set_bar($PCPanel/PanelContainer/PCData/PCHealthBar, BarType.HEALTH, current_player_health, State.max_health)
		
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
	
	current_enemy_health = max(0, current_enemy_health - State.attack_damage)
	set_bar($EnemyContainer/EnemyHealthBar, BarType.HEALTH, current_enemy_health, enemy.health)
	
	$AnimationPlayer.play("enemy_damaged")
	await $AnimationPlayer.animation_finished
	display_text("You dealt %d damage!" % State.attack_damage)
	
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
