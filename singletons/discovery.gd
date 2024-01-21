extends Node

signal server_scanned(server_id: String)
signal server_timed_out(server_id: String, server_data: RServerData)

const D_GAME = "gartofl"
const D_GET_SERVER = "get_server"
const G_SEND_SERVER = "send_server"
const TIME_OUT = 10

const SCANNING_PORT: int = 4040
const SCANNING_TIME: float = 30

var client_discovery: PacketPeerUDP
var server_discovery: UDPServer

var is_scanning: bool = false
var scanned_servers: Dictionary = {}

var is_server: bool = false

var server_data: RServerData

## Scan the network to search for existing server
func scan():
	if self.is_server:
		return
	
	self.client_discovery = PacketPeerUDP.new()
	self.client_discovery.set_broadcast_enabled(true)
	self.client_discovery.set_dest_address("255.255.255.255", SCANNING_PORT)
	self.client_discovery.put_var({
		"game": D_GAME,
		"type": D_GET_SERVER
	})
	
#	get_tree().create_timer(self.SCANNING_TIME).timeout.connect(self.stop_client)
#	scanned_servers = {} # Don't clear previously found server (/!\ servers no longer available are still in the dict) 
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
	
	if data.get("type") == G_SEND_SERVER:
		var _server_data: RServerData = RServerData.new(data.get("data", {}))
		
		var server_ip = client_discovery.get_packet_ip()
		var server_port = _server_data.port
		var server_id = "%s:%s" % [server_ip, server_port]
		
		scanned_servers[server_id] = {
			"last_update": Time.get_unix_time_from_system(),
			"data": _server_data
		}
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
	
	if data.get("type") == D_GET_SERVER:
		peer_discovery.put_var({
			"game": D_GAME,
			"type": G_SEND_SERVER,
			"data": self.server_data.to_dict()
		})

func search_timed_out_servers() -> void:
	var current_time = Time.get_unix_time_from_system()
	for server_id in scanned_servers:
		if current_time - scanned_servers[server_id].last_update > TIME_OUT:
			server_timed_out.emit(server_id, scanned_servers[server_id].data)
			scanned_servers.erase(server_id)

func _process(delta: float) -> void:
	handle_client()
	handle_server()
	search_timed_out_servers()

func as_server():
	if self.client_discovery:
		self.stop_client()
	
	self.server_data = RServerData.new()
	
	self.server_discovery = UDPServer.new()
	var err = self.server_discovery.listen(SCANNING_PORT, "0.0.0.0")
	if err != OK:
		printerr("ERROR - Discovery server listen: %s" % err)
	self.is_server = true

func get_server_data(server_id: String) -> RServerData:
	return scanned_servers[server_id]["data"]
