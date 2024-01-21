extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)

signal all_sentences_received
signal all_drawings_received

var sentences: Array[Dictionary] = []
var drawings: Array[Dictionary] = []

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

@rpc("any_peer", "call_local", "reliable")
func update_drawing(buffer: PackedByteArray):
	var id = multiplayer.get_remote_sender_id()
	while len(drawings) <= current_round:
		drawings.append({})
	
	drawings[current_round][id] = buffer
	if len(drawings[current_round]) == len(players):
		all_drawings_received.emit()

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


## Let everyone know you exist
@rpc("any_peer", "reliable")
func send_ourself(player_info_data: Dictionary):
	var player_info = PlayerInfo.new(player_info_data)
	var peer_id = multiplayer.get_remote_sender_id()
	self.register_player(peer_id, player_info)

## Register a player
func register_player(peer_id: int, player_info: PlayerInfo):
	players[peer_id] = player_info
	self.player_connected.emit(peer_id, player_info)
	self.update_discovery()

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	# Register our self in our session
	self.register_player(peer_id, NetworkManager.player_info)

func _on_player_disconnect(peer_id: int):
	print_debug("%s: (%s) disconnected" % [peer_id, players[peer_id].name])
	players.erase(peer_id)
	self.player_disconnected.emit(peer_id)
	update_discovery()

func _on_player_connect(peer_id):
	print_debug("New player connected: %s" % [peer_id])
	send_ourself.rpc_id(peer_id, NetworkManager.player_info.to_dict())

func _on_server_disconnected():
	print_debug("Server disconnected")
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
	var our_player_id = players_order[our_player_index]
	
	return sentences[current_round][our_player_id]

func get_our_drawing() -> Texture:
	if current_round == 0:
		return null
	
	var our_id = multiplayer.get_unique_id()
	var our_order_index = players_order.find(our_id)
	if our_order_index == -1:
		printerr("Can't find our_id in players_order")
	
	var our_player_index = (our_order_index + 1) % (len(players)) #TODO: may change this?
	var our_player_id = players_order[our_player_index]
	
	var buffer: PackedByteArray = drawings[current_round-1][our_player_id]
	
	var image = Image.create(1920, 1080, true, Image.FORMAT_BPTC_RGBA)
	image.load_png_from_buffer(buffer)
	var tex := ImageTexture.create_from_image(image)
	
	return tex
