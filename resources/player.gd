class_name Player
extends Resource

@export var name: String = ""
@export var placeholder_name: String = ""

func get_player_name():
	return name if not name.is_empty() else placeholder_name
