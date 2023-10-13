extends Control

signal textbox_closed

@onready var hp_labels : Array = []
@onready var hp_bars : Array = []
@onready var party_members : Array = []
@onready var textbox = $MainTextBox/Textbox

@onready var enemy_hp = $EnemyContainer/HP
@onready var enemy_hp_bar = $EnemyContainer/HealthBar

var animated_health1 = 0
var animated_health2 = 0
var animated_health3 = 0
var animated_health_enemy = 0

func _ready():
	set_party_members()
	set_enemy_health()
	textbox.hide()

func _process(delta):
	var round_value = round(animated_health1)
	hp_labels[0].text = str(round_value)
	hp_bars[0].value = round_value
	
	round_value = round(animated_health2)
	hp_labels[1].text = str(round_value)
	hp_bars[1].value = round_value
	
	round_value = round(animated_health3)
	hp_labels[2].text = str(round_value)
	hp_bars[2].value = round_value
	
	round_value = round(animated_health_enemy)
	enemy_hp.text = str(round_value)
	enemy_hp_bar.value = round_value
	
func _on_player_1_health_changed(health):
	update_health(health, 0)

func _on_player_2_health_changed(health):
	update_health(health, 1)

func _on_player_3_health_changed(health):
	update_health(health, 2)
	
func update_health(new_value, player):
	var tween = create_tween()
	match player:
		0:
			tween.tween_property(self, "animated_health1", new_value, 0.6)
		1:
			tween.tween_property(self, "animated_health2", new_value, 0.6)
		2:
			tween.tween_property(self, "animated_health3", new_value, 0.6)
		3:
			tween.tween_property(self, "animated_health_enemy", new_value, 0.6)

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

func _on_enemy_health_changed(health):
	update_health(health, 3)

func set_party_members():
	party_members.append($PartyPanel/PartyMemberContainer1/MarginContainer/PartyMemberData)
	party_members.append($PartyPanel/PartyMemberContainer2/MarginContainer/PartyMemberData)
	party_members.append($PartyPanel/PartyMemberContainer3/MarginContainer/PartyMemberData)
	set_party_health()
	set_party_portraits()
	set_party_names()
	
func set_party_health():
	hp_labels.append(party_members[0].get_node("GridContainer/HPContainer/HP"))
	hp_labels.append(party_members[1].get_node("GridContainer/HPContainer/HP"))
	hp_labels.append(party_members[2].get_node("GridContainer/HPContainer/HP"))
	
	hp_bars.append(party_members[0].get_node("GridContainer/HPContainer/HealthBar"))
	hp_bars.append(party_members[1].get_node("GridContainer/HPContainer/HealthBar"))
	hp_bars.append(party_members[2].get_node("GridContainer/HPContainer/HealthBar"))
		
	var player1_max_health = $"../Characters/Player1".max_health
	hp_bars[0].max_value = player1_max_health
	update_health(player1_max_health, 0)
	
	var player2_max_health = $"../Characters/Player2".max_health
	hp_bars[1].max_value = player2_max_health
	update_health(player2_max_health, 1)
	
	var player3_max_health = $"../Characters/Player3".max_health
	hp_bars[2].max_value = player3_max_health
	update_health(player3_max_health, 2)

func set_party_portraits():
	party_members[0].get_node("Portrait").texture = $"../Characters/Player1".portrait
	party_members[1].get_node("Portrait").texture = $"../Characters/Player2".portrait
	party_members[2].get_node("Portrait").texture = $"../Characters/Player3".portrait

func set_party_names():
	party_members[0].get_node("GridContainer/Name").text = $"../Characters/Player1".char_name
	party_members[1].get_node("GridContainer/Name").text = $"../Characters/Player2".char_name
	party_members[2].get_node("GridContainer/Name").text = $"../Characters/Player3".char_name

func _on_battle_active_player_changed(char_name):
	for x in party_members:
		if x.get_node("GridContainer/Name").text == char_name:
			x.get_node("Portrait/Panel").show()
		else: 
			x.get_node("Portrait/Panel").hide()

func set_enemy_health():
	var enemy_max_health = $"../Characters/Enemy".max_health
	enemy_hp_bar.max_value = enemy_max_health
	update_health(enemy_max_health, 3)
	$EnemyContainer/EnemySprite.texture = $"../Characters/Enemy".texture
