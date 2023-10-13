extends Node2D

class_name  TurnQueue

@onready var active_combatant 

func initialize():
	var combatants = get_children()
	combatants.sort_custom(sort_combatants)
	active_combatant = get_child(0)

static func sort_combatants(a, b) -> bool:
	return a.speed < b.speed
	
func play_turn(target):
	await active_combatant.play_turn(target)
	var new_index : int = (active_combatant.get_index() + 1) % get_child_count()
	active_combatant = get_child(new_index)

func get_party():
	var party_members : Array = []
	for child in get_children():
		if child.is_party_member && child.current_health > 0:
			party_members.append(child)
	return party_members
	
func get_opponents():
	var opponents : Array = []
	for child in get_children():
		if child.is_party_member == false && child.current_health > 0:
			opponents.append(child)
	return opponents
	
func print_queue():
	"""Prints the Combatants' and their speed in the turn order"""
	var string : String = ""
	for combatant in get_children():
		string += combatant.name + "(%s)" % combatant.speed + " "
	print(string)
	
