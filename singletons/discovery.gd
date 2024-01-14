extends Node

signal server_scanned(server_id: String, server_data: Dictionary)

const D_GAME = "gartofl"
const D_GET_SERVER = "get_server"
const G_SEND_SERVER = "send_server"

const SCANNING_PORT: int = 4040
const SCANNING_TIME: float = 1

var client_discovery: PacketPeerUDP
var server_discovery: UDPServer

var is_scanning: bool = false
var scanned_servers: Dictionary = {}

var is_server: bool = false

var server_data: Dictionary = {"err": "no data"}

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
	
	get_tree().create_timer(self.SCANNING_TIME).timeout.connect(self.stop_client)
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
	
	var server_ip = client_discovery.get_packet_ip()
	var server_port = client_discovery.get_packet_port()
	var server_id = "%s:%s" % [server_ip, server_port]
	
	if data.get("type") == G_SEND_SERVER and not server_id in scanned_servers:
		var server_data = data.get("data", {})
		
		server_data["ip"] = server_ip
		
		scanned_servers[server_id] = server_data
		server_scanned.emit(server_id, server_data)



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
	print(data)
	if data == null:
		return
	
	if data.get("game") != D_GAME:
		return
	
	if data.get("type") == D_GET_SERVER:
		peer_discovery.put_var({
			"game": D_GAME,
			"type": G_SEND_SERVER,
			"data": self.server_data
		})

func _process(delta: float) -> void:
	handle_client()
	handle_server()

func as_server(data: Dictionary):
	if self.client_discovery:
		self.stop_client()
	
	self.server_data = data
	
	self.server_discovery = UDPServer.new()
	var err = self.server_discovery.listen(SCANNING_PORT, "0.0.0.0")
	if err != OK:
		printerr("ERROR - Discovery server listen: %s" % err)
	self.is_server = true
