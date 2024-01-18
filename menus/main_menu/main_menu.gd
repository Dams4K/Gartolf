extends Control

@onready var player_name_line_edit: LineEdit = %PlayerNameLineEdit
@onready var port_line_edit: LineEdit = %PortLineEdit
@onready var servers_container: VBoxContainer = %ServersContainer

func _ready() -> void:
	player_name_line_edit.placeholder_text = NetworkManager.DEFAULT_PLAYER_NAME
	port_line_edit.placeholder_text = str(NetworkManager.DEFAULT_PORT)
	Discovery.server_scanned.connect(_on_server_scanned)
	Discovery.scan()
	
	multiplayer.connected_to_server.connect(_on_connected_ok)


func _on_host_button_pressed() -> void:
	var port: String = port_line_edit.text
	if port.is_empty():
		port = port_line_edit.placeholder_text
	
	var err = NetworkManager.create_server(port.to_int())
	if err == OK: # No error
		get_tree().change_scene_to_file("res://menus/lobby_menu.tscn")


func _on_join_button_pressed() -> void:
	var err = NetworkManager.join_server("127.0.0.1")
	if err == OK: # No error
		pass


func _on_player_name_line_edit_text_changed(new_text: String) -> void:
	NetworkManager.set_player_name(new_text)


func _on_port_line_edit_text_changed(new_text: String) -> void:
	pass # TODO

func _on_connected_ok():
	get_tree().change_scene_to_file("res://menus/lobby_menu.tscn")

func _on_scan_button_pressed() -> void:
	Discovery.scan()


func _on_timer_timeout() -> void:
	Discovery.scan()

func _on_server_scanned(id: String, data: Dictionary):
	var btn = Button.new()
	btn.name = id
	btn.text = "%s/%s" % ["?", data["max_players"]]
	btn.pressed.connect(join_server.bind(id))
	
	servers_container.add_child(btn)


func join_server(server_id: String) -> void:
	var server_data = Discovery.scanned_servers[server_id]
	var server_ip = server_data["ip"]
	var server_port = server_data["port"]
	var err = NetworkManager.join_server(server_ip, server_port)

