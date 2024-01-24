extends Button

var server: ServerDiscovered

@onready var status_label: Label = %StatusLabel
@onready var players_label: Label = %PlayersLabel

var total_players: int = -1
var max_players: int = -1

func _ready() -> void:
	if server:
		max_players = server.server_data.max_players
		server.new_status.connect(_on_new_status)
		server.total_player_changed.connect(_on_total_player_changed)
		
		_on_new_status(server.server_data.status)
		_on_total_player_changed(server.server_data.total_players)

func update_players_label():
	players_label.text = "%s/%s" % [total_players, max_players]

func _on_new_status(status: RServerData.STATUS) -> void:
	match status:
		RServerData.STATUS.OPEN:
			status_label.modulate = Color.GREEN
		RServerData.STATUS.PLAYING:
			status_label.modulate = Color.RED
			disabled = true
	
	status_label.text = RServerData.STATUS.keys()[status]

func _on_total_player_changed(value: int):
	total_players = value
	max_players = server.server_data.max_players
	update_players_label()

func _process(delta: float) -> void:
	if disabled:
		modulate = Color("#cccccc")
	else:
		modulate = Color.WHITE
