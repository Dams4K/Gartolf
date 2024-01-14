## That's funny
extends Node

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

## Default port
const DEFAULT_PORT: int = 4242
## Default max player amount
const MAX_PLAYER: int = 64
## Default PlayerName
const DEFAULT_PLAYER_NAME: String = "DefaultName"


## Multiplayer peer
var peer: ENetMultiplayerPeer

## All players in the server
var players: Dictionary = {}

## Current player information
var player_info: Dictionary = {
	"name": DEFAULT_PLAYER_NAME
}

# TODO: may replace player_info dict by a Resource?
func set_player_name(value: String) -> void:
	if value.is_empty():
		value = DEFAULT_PLAYER_NAME
	player_info.name = value

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)



## Create server
func create_server(port: int = DEFAULT_PORT, max_players: int = MAX_PLAYER) -> int:
	Discovery.as_server({
		"max_players": max_players,
		"port": port
	})
	
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, MAX_PLAYER) #TODO: catch errors
	multiplayer.multiplayer_peer = peer
	
	players[1] = player_info
	player_connected.emit(1, player_info)
	
#	server_discovery = UDPServer.new()
#	server_discovery.listen(SCANNING_PORT, "0.0.0.0")
#	is_server = true
	
	return err


## Join server (Create client)
func join_server(addr: String, port: int = DEFAULT_PORT) -> int:
#	is_scanning = false
#	client_discovery.close()
	Discovery.stop_client()
	
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(addr, port) #TODO: catch errors
	multiplayer.multiplayer_peer = peer
	
	return err

func _on_player_connected(id):
	_register_player.rpc_id(id, player_info)


@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)


func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)


func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)


func _on_connected_fail():
	multiplayer.multiplayer_peer = null


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
