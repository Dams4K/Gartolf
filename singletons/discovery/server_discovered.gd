class_name ServerDiscovered
extends Node

signal new_status
signal total_player_changed

const UPDATE_TIME = 2

var PORT = ProjectSettings.get("application/discovery/port")

var ip: String
var server_data: RServerData

var client: PacketPeerUDP

@onready var timer: Timer

func _init(_ip: String):
	self.ip = _ip


func _ready() -> void:
	client = PacketPeerUDP.new()
	client.connect_to_host(ip, PORT)
	
	timer = Timer.new()
	timer.wait_time = UPDATE_TIME
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()
	
	update()


func _process(_delta: float) -> void:
	handle_packets()


func handle_packets():
	if client.get_available_packet_count() == 0:
		return
	
	var packet = client.get_packet()
	if packet.is_empty():
		return
	
	var data = packet.decode_var(0)
	
	if data == null:
		return
	if data.get("game") != Discovery.D_GAME:
		return
	
	if data.get("answer_for") == Discovery.Requests.GET_SERVER:
		var new_server_data := RServerData.new(data.get("data", {}))
		
		if new_server_data.port != server_data.port:
			return
		
		var old_server_data = server_data
		server_data = new_server_data
		
		if old_server_data.status != new_server_data.status:
			new_status.emit(new_server_data.status)
		if old_server_data.total_players != new_server_data.total_players:
			total_player_changed.emit(new_server_data.total_players)


func _on_timer_timeout():
	update()


func update():
	client.put_var({
		"game": Discovery.D_GAME,
		"request": Discovery.Requests.GET_SERVER
	})

func get_id() -> String:
	return "%s_%s" % [ip.replace(".", "_"), server_data.port]
