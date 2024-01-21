extends Control

const SERVER_BUTTON: PackedScene = preload("res://menus/main_menu/server_button.tscn")
var PSEUDOS: Array[StringName] = [
	"Grimdal",
	"Raptor",
	"PetiteFée",
	"Pewfan",
	"Seltade",
	"Kairrin",
	"Potaaato",
	"Neptendus",
	"RainbowMan",
	"Exominiate",
	"Meyriu",
	"Ectobiologiste",
	"ItsGodHere",
	"MaxMadMen",
	"TankerTanker",
	"Felipero",
	"TheFlyingBat",
	"JustEpic",
	"LeGrandBlond",
	"Azalee",
	"OarisKiller",
	"LeHamster",
	"Dialove",
	"Frexs",
	"Rofaly",
	"GeoMan",
	"Kirna",
	"Gruty",
	"Fridame",
	"Fluxy",
	"Drastics",
	"Grimace",
	"Viiper",
	"xXSerpentXx",
	"Cristobal",
	"Scubrina",
	"Xanoneq",
	"McTimley",
	"LittleDank",
	"Rocketman"
]

@onready var player_name_line_edit: LineEdit = %PlayerNameLineEdit
@onready var port_line_edit: LineEdit = %PortLineEdit
@onready var servers_container: VBoxContainer = %ServersContainer
@onready var empty_label: Label = %EmptyLabel
@onready var error_host_label: Label = %ErrorHostLabel

func _ready() -> void:
	randomize()
	PSEUDOS.shuffle()
	player_name_line_edit.placeholder_text = PSEUDOS[0]
	
	port_line_edit.placeholder_text = str(NetworkManager.DEFAULT_PORT)
	
	error_host_label.text = ""
	
	Discovery.server_scanned.connect(_on_server_scanned)
	Discovery.server_timed_out.connect(_on_server_timed_out)
	Discovery.scan()
	
	multiplayer.connected_to_server.connect(_on_connected_ok)


func _on_host_button_pressed() -> void:
	set_player_name()
	
	var port: String = port_line_edit.text
	if port.is_empty():
		port = port_line_edit.placeholder_text
	
	var err = NetworkManager.create_server(port.to_int())
	match err:
		OK:
			get_tree().change_scene_to_file("res://menus/lobby_menu.tscn")
		ERR_CANT_CREATE:
			show_host_error("Ouverture impossible avec le port %s" % port)


func _on_join_button_pressed() -> void:
	var err = NetworkManager.join_server("127.0.0.1")
	if err == OK: # No error
		pass


func _on_port_line_edit_text_changed(new_text: String) -> void:
	pass # TODO

func _on_connected_ok():
	get_tree().change_scene_to_file("res://menus/lobby_menu.tscn")

func _on_scan_button_pressed() -> void:
	Discovery.scan()


func _on_timer_timeout() -> void:
	Discovery.scan()

func _on_server_scanned(server_id: String):
	var server_data: RServerData = Discovery.get_server_data(server_id)
	var node_name = server_id.replace(".", "_").replace(":", "_")
	
	var server_btn = servers_container.get_node_or_null(node_name)
	
	if not server_btn:
		empty_label.hide()
		
		server_btn = SERVER_BUTTON.instantiate()
		server_btn.name = node_name
		server_btn.pressed.connect(join_server.bind(server_id))
		
		servers_container.add_child(server_btn)
	
	server_btn.status = server_data.status
	server_btn.total_players = server_data.total_players
	server_btn.max_players = server_data.max_players


func _on_server_timed_out(server_id: String, server_data: RServerData):
	var node_name = server_id.replace(".", "_").replace(":", "_")
	var node = servers_container.get_node_or_null(node_name)
	if node:
		servers_container.remove_child(node)
		node.queue_free()
	
	if servers_container.get_child_count() == 1: # the 1 is empty_label
		empty_label.show()

func join_server(server_id: String) -> void:
	set_player_name()
	var server_data = Discovery.get_server_data(server_id)
	var server_ip = server_id.split(":")[0]
	var server_port = server_data.port
	var err = NetworkManager.join_server(server_ip, server_port)

func show_host_error(message: String) -> void:
	error_host_label.text = message


func _on_add_server_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menus/add_server_menu.tscn")

func set_player_name():
	var player_name: StringName = player_name_line_edit.text
	if player_name.is_empty():
		player_name = player_name_line_edit.placeholder_text
	
	NetworkManager.set_player_name(player_name)
