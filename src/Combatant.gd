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
var active_player : bool = false

signal health_changed
signal died

func play_turn(target):
	attack(target)

func attack(target):
	print("%s attacks %s" % [char_name, target.char_name])
	await get_tree().create_timer(1).timeout
	target.take_damage(attack_damage)
	print("%s dealt %s %d damage!" % [char_name, target.char_name, attack_damage])
	

func take_damage(damage):
	current_health = max(0, current_health - damage)
	emit_signal("health_changed",current_health)
		
	if current_health == 0:
		die()
		
	$AnimationPlayer.play("take_hit")
	await $AnimationPlayer.animation_finished
	

func die():
	print("%s is defeated!" % char_name)
	emit_signal("died")
	
	var end_color = Color(1.0, 1.0, 1.0, 0.0)
	var tween = create_tween()
	tween.tween_property(self, "modulate", end_color, 0.6)
