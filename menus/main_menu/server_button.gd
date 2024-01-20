extends Button

@export var status: RServerData.STATUS = RServerData.STATUS.OPEN : set = set_status
@export var max_players: int = 64 : set = set_max_players
@export var total_players: int = 0 : set = set_total_players

@onready var status_label: Label = %StatusLabel
@onready var players_label: Label = %PlayersLabel

func update_players_label():
	players_label.text = "%s/%s" % [total_players, max_players]

func set_status(value: RServerData.STATUS) -> void:
	status = value
	
	match status:
		RServerData.STATUS.OPEN:
			status_label.modulate = Color.GREEN
		RServerData.STATUS.PLAYING:
			status_label.modulate = Color.RED
			disabled = true
	
	status_label.text = RServerData.STATUS.keys()[value]

func set_max_players(value: int):
	max_players = value
	update_players_label()

func set_total_players(value: int):
	total_players = value
	update_players_label()

func _process(delta: float) -> void:
	if disabled:
		modulate = Color("#cccccc")
	else:
		modulate = Color.WHITE
