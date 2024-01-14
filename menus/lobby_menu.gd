extends CenterContainer

@onready var players_container: VBoxContainer = %PlayersContainer

func _ready() -> void:
	# Load existing players
	for peer_id in NetworkManager.players:
		_on_player_join(peer_id, NetworkManager.players[peer_id])
	
	NetworkManager.player_connected.connect(_on_player_join)

func _on_player_join(peer_id: int, player_info: Dictionary):
	var label = Label.new()
	label.name = str(peer_id)
	label.text = player_info.name
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	players_container.add_child(label)
