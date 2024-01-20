extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal all_sentences_received()

var sentences = []

var has_started: bool = false

## All players in the server
var players: Dictionary = {}

## Store players id in a specific order
var players_order: Array = [
	
]

var current_round: int = 0

func _ready() -> void:
	randomize()
	NetworkManager.player_disconnected.connect(_on_player_disconnect)
	NetworkManager.player_connected.connect(_on_player_connect)
	NetworkManager.connected_to_server.connect(_on_connected_ok)
	NetworkManager.server_disconnected.connect(_on_server_disconnected)


@rpc("any_peer", "call_local", "reliable")
func update_sentence(sentence: String):
	var id = multiplayer.get_remote_sender_id()
	while len(sentences) <= current_round:
		sentences.append({})
	
	sentences[current_round][id] = sentence
	if len(sentences[current_round]) == len(players):
		all_sentences_received.emit()

func start_game():
	if multiplayer.is_server():
		has_started = true
		NetworkManager.allow_connection = false
		Discovery.server_data.status = RServerData.STATUS.PLAYING
		var local_players_order = players.keys()
		local_players_order.shuffle()
		set_players_order.rpc(local_players_order)


@rpc("authority", "call_local", "reliable")
func set_players_order(order: Array):
	players_order = order


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

func get_our_sentence():
	var our_id = multiplayer.get_unique_id()
	var our_order_index = players_order.find(our_id)
	if our_order_index == -1:
		printerr("Can't find our_id in players_order")
	
	var our_player_index = (our_order_index + 1) % len(players)
	printt(our_order_index, our_player_index, sentences)
	var our_player_id = players.keys()[our_player_index]
	return sentences[current_round][our_player_id]
