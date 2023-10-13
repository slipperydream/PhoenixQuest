extends Control

signal textbox_closed

@onready var hp_label1 = $PartyPanel/PartyMemberContainer1/MarginContainer/PartyMemberData/GridContainer/HPContainer/HP
@onready var hp_label2 = $PartyPanel/PartyMemberContainer2/MarginContainer/PartyMemberData/GridContainer/HPContainer/HP
@onready var hp_label3 = $PartyPanel/PartyMemberContainer3/MarginContainer/PartyMemberData/GridContainer/HPContainer/HP

@onready var hp_bar1 = $PartyPanel/PartyMemberContainer1/MarginContainer/PartyMemberData/GridContainer/HPContainer/HealthBar
@onready var hp_bar2 = $PartyPanel/PartyMemberContainer2/MarginContainer/PartyMemberData/GridContainer/HPContainer/HealthBar
@onready var hp_bar3 = $PartyPanel/PartyMemberContainer3/MarginContainer/PartyMemberData/GridContainer/HPContainer/HealthBar

@onready var textbox = $MainTextBox/Textbox

func _ready():
	var player1_max_health = $"../Characters/Player1".max_health
	hp_bar1.max_value = player1_max_health
	update_health(player1_max_health, 1)
	
	var player2_max_health = $"../Characters/Player2".max_health
	hp_bar2.max_value = player2_max_health
	update_health(player2_max_health, 2)
	
	var player3_max_health = $"../Characters/Player3".max_health
	hp_bar3.max_value = player3_max_health
	update_health(player3_max_health, 3)
	
	textbox.hide()

func _on_player_1_health_changed(health):
	update_health(health, 1)

func _on_player_2_health_changed(health):
	update_health(health, 2)

func _on_player_3_health_changed(health):
	update_health(health, 3)
	
func update_health(new_value, player):
	match player:
		1: 
			hp_label1.text = str(new_value)
			hp_bar1.value = new_value
		2: 
			hp_label2.text = str(new_value)
			hp_bar2.value = new_value
		3: 
			hp_label3.text = str(new_value)
			hp_bar3.value = new_value

func display_text(text):
	textbox.show()
	textbox.get_node("Text").text = text

func _on_battle_ran_away():
	display_text("Got away safely!")
	await self.textbox_closed
	for x in $GeneralActions.get_tree().get_nodes_in_group("combat"):
		x.hide()

func _on_battle_battle_over():
	display_text("Battle is over, choom!")
	await self.textbox_closed

func _input(event):
	if (Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)) and textbox.visible:
		textbox.hide()
		emit_signal("textbox_closed")

func _on_battle_enemy_appears(enemy_name):
	display_text("A %s appears. Watch out choom!" % enemy_name)
	await self.textbox_closed
