extends Node

signal server_scanned(server_id: String)
signal server_timed_out(server_id: String, server_data: RServerData)


enum Requests {
	GET_SERVER
}

const D_GAME = "gartofl"
const D_GET_SERVER = "get_server"
const D_SEND_SERVER = "send_server"
const D_UPDATE_SERVER = "update_server"

const TIME_OUT = 10

var SCANNING_PORT: int = ProjectSettings.get("application/discovery/port")
const SCANNING_TIME: float = 30

var client_discovery: PacketPeerUDP
var server_discovery: UDPServer

var is_scanning: bool = false

var is_server: bool = false

var server_data: RServerData

@onready var custom_servers: CustomServers

@onready var update_timer: Timer

func _ready() -> void:
	as_client()
	
	custom_servers = CustomServers.setup()
	custom_servers.server_added.connect(_on_custom_server_added)
	
	for server in custom_servers.get_server_nodes():
		add_child(server)
		server_scanned.emit(server.get_id())


func _on_custom_server_added(index: int):
	var server = custom_servers.get_server_node(index)
	add_child(server)
	server_scanned.emit(server.get_id())


func _process(_delta: float) -> void:
	handle_client()
	handle_server()


## Scan the network to search for existing server
func scan():
	if is_server:
		return
	
	client_discovery.put_var({
		"game": D_GAME,
		"request": Requests.GET_SERVER
	})
	
	get_tree().create_timer(self.SCANNING_TIME).timeout.connect(self.stop_client)
	self.is_scanning = true

func stop_client():
	is_scanning = false
	if client_discovery:
		client_discovery.close()

func handle_client():
	if is_server or client_discovery == null or not is_scanning:
		return
	
	if client_discovery.get_available_packet_count() == 0:
		return
	
	var data: Dictionary = client_discovery.get_packet().decode_var(0)
	
	if data == null:
		return
	if data.get("game") != D_GAME:
		return
	
	
	if data.get("answer_for") == Requests.GET_SERVER:
		var _server_data: RServerData = RServerData.new(data.get("data", {}))
		var server_ip = client_discovery.get_packet_ip()
		var server := ServerDiscovered.new(server_ip)
		server.server_data = _server_data
		var server_id: String = server.get_id()
		
		server.name = server_id
		if not has_node(server_id):
			add_child(server)
			server_scanned.emit(server_id)


func handle_server():
	if not is_server:
		return
	if not server_discovery:
		return
	
	server_discovery.poll()
	if not server_discovery.is_connection_available():
		return
	
	var peer_discovery: PacketPeerUDP = server_discovery.take_connection()
	var data = peer_discovery.get_packet().decode_var(0)
	
	if data == null:
		return
	if data.get("game") != D_GAME:
		return
	
	if data.get("request") == Requests.GET_SERVER:
		peer_discovery.put_var({
			"game": D_GAME,
			"answer_for": Requests.GET_SERVER,
			"data": server_data.to_dict()
		})


func as_client():
	if client_discovery:
		stop_client()
	
	client_discovery = PacketPeerUDP.new()
	client_discovery.set_broadcast_enabled(true)
	client_discovery.set_dest_address("255.255.255.255", SCANNING_PORT)


func as_server():
	if client_discovery:
		stop_client()
	
	server_data = RServerData.new()
	server_data.status = RServerData.STATUS.OPEN
	
	server_discovery = UDPServer.new()
	var err = server_discovery.listen(SCANNING_PORT, "0.0.0.0")
	if err != OK:
		printerr("ERROR - Discovery server listen: %s" % err)
	is_server = true


func _on_update_timer_timeout():
	if not is_server:
		print_debug("Send update packet")
		client_discovery.put_var({
			"game": D_GAME,
			"type": D_UPDATE_SERVER
		})
