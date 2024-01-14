extends Control

@onready var players_container: VBoxContainer = %PlayersContainer
@onready var ready_label: Label = %ReadyLabel
@onready var force_start: Button = %ForceStart

var players_ready: Array[int] = []

func _ready() -> void:
	force_start.visible = multiplayer.is_server()
	# Load existing players
	for peer_id in NetworkManager.players:
		_on_player_join(peer_id, NetworkManager.players[peer_id])
	
	NetworkManager.player_connected.connect(_on_player_join)

func _on_player_join(peer_id: int, player_info: Dictionary):
	var label = Label.new()
	label.name = str(peer_id)
	label.text = player_info.name
	label.modulate = Color.RED
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	players_container.add_child(label)
	update_ready_label()


func _on_ready_button_pressed() -> void:
	toggle_ready.rpc()

@rpc("any_peer", "call_local", "reliable")
func toggle_ready():
	var id = multiplayer.get_remote_sender_id()
	var label: Label = players_container.get_node(str(id))
	if label == null:
		printerr("toggle_ready - label %s don't exist" % id)
	
	if id in players_ready:
		players_ready.erase(id)
		label.modulate = Color.RED
	else:
		players_ready.append(id)
		label.modulate = Color.GREEN
	
	update_ready_label()
	
	if multiplayer.is_server() and len(players_ready) == len(NetworkManager.players):
		start_game.rpc()

@rpc("call_local", "reliable")
func start_game():
	get_tree().change_scene_to_file("res://menus/drawing/drawing_menu.tscn")

func update_ready_label():
	ready_label.text = "Ready : %s/%s" % [len(players_ready), len(NetworkManager.players)]


func _on_force_start_pressed() -> void:
	start_game.rpc()
