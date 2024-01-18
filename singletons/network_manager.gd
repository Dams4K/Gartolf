## That's funny
extends Node

## I will use NetworkManager.connected_to_server instead multiplayer.connected_to_server, allowing me to add logic between the network and the game
signal connected_to_server
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

## Current player information
## TODO: move this somewhere else
var player_info: Dictionary = {
	"name": DEFAULT_PLAYER_NAME
}

var allow_connection: bool = true

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
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_server(port, MAX_PLAYER) #TODO: catch errors
	if err != OK:
		printerr("Can't create server with port %s" % port)
		return err
	
	Discovery.as_server({
		"max_players": max_players,
		"port": port
	})
	
	multiplayer.multiplayer_peer = peer
	
	connected_to_server.emit()
	
	return err


## Join server (Create client)
func join_server(addr: String, port: int = DEFAULT_PORT) -> int:
	peer = ENetMultiplayerPeer.new()
	var err = peer.create_client(addr, port) #TODO: catch errors
	multiplayer.multiplayer_peer = peer
	
	return err

# Called for everyone already connected + the one who just connect
func _on_player_connected(peer_id):
	if multiplayer.is_server() and not allow_connection:
		peer.disconnect_peer(peer_id)
	else:
		player_connected.emit(peer_id, player_info)


func _on_player_disconnected(id):
	player_disconnected.emit(id)


## Called for the one who just connect
func _on_connected_ok():
	connected_to_server.emit()


func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	print("connection failed")
	open_menu()


func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	server_disconnected.emit()
	open_menu()

func open_menu():
	get_tree().change_scene_to_file("res://menus/main_menu/main_menu.tscn")
