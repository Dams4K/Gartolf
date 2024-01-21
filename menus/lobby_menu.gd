extends Control

@onready var players_container: VBoxContainer = %PlayersContainer
@onready var ready_label: Label = %ReadyLabel
@onready var force_start: Button = %ForceStart

var players_ready: Array[int] = []

func _ready() -> void:
	force_start.visible = multiplayer.is_server()
	# Load existing players
	for peer_id in GameManager.players:
		_on_player_join(peer_id, GameManager.players[peer_id])
	
	GameManager.player_connected.connect(_on_player_join)
	GameManager.player_disconnected.connect(_on_player_quit)

func _on_player_join(peer_id: int, player_info):
	var label = Label.new()
	label.name = str(peer_id)
	label.text = player_info.get_player_name()
	label.modulate = Color.RED
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	players_container.add_child(label)
	update_ready_label()


func _on_player_quit(peer_id: int):
	var label = players_container.get_node_or_null(str(peer_id))
	if label:
		label.queue_free()
	update_ready_label()


func _on_ready_button_pressed() -> void:
	toggle_ready.rpc()

@rpc("any_peer", "call_local", "reliable")
func toggle_ready():
	var id = multiplayer.get_remote_sender_id()
	var label: Label = players_container.get_node_or_null(str(id))
	if label == null:
		printerr("toggle_ready - label %s don't exist" % id)
	
	if id in players_ready:
		players_ready.erase(id)
		label.modulate = Color.RED
	else:
		players_ready.append(id)
		label.modulate = Color.GREEN
	
	update_ready_label()
	
	if multiplayer.is_server() and len(players_ready) == len(GameManager.players):
		start_game.rpc()

@rpc("call_local", "reliable")
func start_game():
	GameManager.start_game()
	get_tree().change_scene_to_file("res://menus/sentence_menu.tscn")

func update_ready_label():
	ready_label.text = "Ready : %s/%s" % [len(players_ready), len(GameManager.players)]


func _on_force_start_pressed() -> void:
	start_game.rpc()
