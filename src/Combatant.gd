extends Node2D

class_name Combatant

@export var char_name : String = "Player"
@export var portrait : Texture = null
@export var texture : Texture = null
@export var is_party_member : bool = false

@export var current_health = 35
@export var max_health = 35
@export var attack_damage = 20
@export var speed = 10

signal health_changed
signal died

func play_turn(target):
	attack(target)

func attack(target):
	print("%s attacks %s" % [char_name, target.char_name])
	target.take_damage(attack_damage)
	print("%s dealt %s %d damage!" % [char_name, target.char_name, attack_damage])
	

func take_damage(damage):
	current_health = max(0, current_health - damage)
	emit_signal("health_changed",current_health)
	
	var tween = create_tween()
	var start_color = Color(1.0, 1.0, 1.0, 1.0)
	var end_color = Color(1.0, 1.0, 1.0, 0.0)
	tween.tween_property(self, "modulate", end_color, 0.2)
	tween.tween_property(self, "modulate", start_color, 0.2)
		
	if current_health == 0:
		die()

func die():
	print("%s is defeated!" % char_name)
	emit_signal("died")
	
	var end_color = Color(1.0, 1.0, 1.0, 0.0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", end_color, 0.6)
