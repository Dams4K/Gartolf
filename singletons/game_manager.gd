extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)

var sentences = []

var has_started: bool = false

## All players in the server
var players: Dictionary = {}

func _ready() -> void:
	NetworkManager.player_disconnected.connect(_on_player_disconnect)
	NetworkManager.player_connected.connect(_on_player_connect)
	NetworkManager.connected_to_server.connect(_on_connected_ok)
	NetworkManager.server_disconnected.connect(_on_server_disconnected)


@rpc("any_peer", "call_local", "reliable")
func update_sentence(sentence: String, round: int):
	var id = multiplayer.get_remote_sender_id()
	while len(sentences) <= round:
		sentences.append({})
	
	sentences[round][id] = sentence


func start_game():
	if multiplayer.is_server():
		has_started = true
		NetworkManager.allow_connection = false
		Discovery.server_data.status = RServerData.STATUS.PLAYING


@rpc("any_peer", "call_local", "reliable")
func register_player(new_player_info):
	var peer_id = multiplayer.get_remote_sender_id()
	self._register_player(peer_id, new_player_info)

func _register_player(peer_id, new_player_info):
	players[peer_id] = new_player_info
	self.player_connected.emit(peer_id, new_player_info)
	self.update_discovery()

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	# Register the player in his session
	self._register_player(peer_id, NetworkManager.player_info)

func _on_player_disconnect(peer_id: int):
	players.erase(peer_id)
	self.player_disconnected.emit(peer_id)
	update_discovery()

func _on_player_connect(peer_id, player_info):
	register_player.rpc_id(peer_id, player_info)

func _on_server_disconnected():
	self.players.clear()

func update_discovery():
	if multiplayer.is_server():
		Discovery.server_data.total_players = len(players)
