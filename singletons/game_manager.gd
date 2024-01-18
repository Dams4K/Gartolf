extends Node

signal player_connected(peer_id, player_info)

var sentences = []

var has_started: bool = false
var allow_player_connection: bool = true

## All players in the server
var players: Dictionary = {}

func _ready() -> void:
	NetworkManager.player_disconnected.connect(_on_player_disconnect)
	NetworkManager.player_connected.connect(_on_player_connect)

@rpc("any_peer", "call_local", "reliable")
func update_sentence(sentence: String, round: int):
	var id = multiplayer.get_remote_sender_id()
	while len(sentences) <= round:
		sentences.append({})
	
	sentences[0][id] = sentence


func start_game():
	has_started = true
	allow_player_connection = false


@rpc("any_peer", "reliable")
func register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnect(id: int):
	players.erase(id)

func _on_player_connect(peer_id, player_info):
#	if not multiplayer.is_server(): return
	
	if allow_player_connection or multiplayer.is_server(): # Of course we want the server
		players[peer_id] = player_info
		print("connect:", peer_id)
