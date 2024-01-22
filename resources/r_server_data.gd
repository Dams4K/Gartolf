class_name RServerData
extends Resource

enum STATUS {
	OPEN,
	PLAYING,
	UNKOWN
}

@export var address: String = "localhost"
@export var port: int = 4242
@export var max_players: int = -1
@export var total_players: int = -1
@export var status: STATUS = STATUS.UNKOWN

func to_dict() -> Dictionary:
	return {
		"port": port,
		"max_players": max_players,
		"total_players": total_players,
		"status": status
	}

func _init(data: Dictionary = {}) -> void:
	if !data.is_empty():
		port = data.get("port", 0)
		max_players = data.get("max_players", 0)
		total_players = data.get("total_players", 0)
		status = data.get("status", STATUS.OPEN)

func get_id() -> String:
	return "%s:%s" % [self.address, self.port]
