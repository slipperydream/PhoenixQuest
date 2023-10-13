extends Control

signal ran_away
signal battle_over
signal enemy_appears

enum BarType {HEALTH, ENERGY}

var enemy : Combatant = null
var party : Array[Combatant] = []
var party_hp_bars = []

var is_defending = false
var turns : int = 0

# set up subscenes
@onready var textbox = $MainTextBox
#@onready var bottom_actions =
@onready var turn_queue : TurnQueue = $Characters


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
	
	emit_signal("enemy_appears", enemy.char_name)	
	play_turn()

func set_party_display():	
	# Draw characters on screen
	$PartyMember1.texture = party[0].texture
	$PartyMember1.set_flip_h(true)
	$PartyMember2.texture = party[1].texture
	$PartyMember3.texture = party[2].texture

	
func _input(event):		
	if Input.is_action_just_pressed("attack"):
		pass
	elif Input.is_action_just_pressed("run_away"):
		run()

func get_active_combatant():
	return turn_queue.active_combatant
		
func play_turn():
	var combatant : Combatant = get_active_combatant()
	var targets : Array = get_targets()
	if not targets:
		end_battle()
		return
	var target : Combatant
	if combatant.is_party_member:
		# TODO add user selection of target
		target = targets[randi() % targets.size()]
	else:
		target = targets[randi() % targets.size()]
		
	await turn_queue.play_turn(target)
	await get_tree().create_timer(0.5).timeout
	if turns < 5:
		turns += 1
		play_turn()

func run():
	emit_signal("ran_away")
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()
	
func end_battle():
	emit_signal("battle_over")

func get_targets():
	if get_active_combatant().is_party_member:
		return turn_queue.get_opponents()
	else:
		return turn_queue.get_party()
