extends Control

const SENTENCE_PANEL: PackedScene = preload("res://menus/end_menu/sentence_panel.tscn")
const DRAWING_PANEL: PackedScene = preload("res://menus/end_menu/drawing_panel.tscn")

@onready var player_list_container: VBoxContainer = %PlayerListContainer
@onready var round_history_container: VBoxContainer = %RoundHistoryContainer

func _ready() -> void:
	create_player_buttons()
	display_player_round(GameManager.players_order[0])

func create_player_buttons():
	for player_id in GameManager.players_order:
		var btn = Button.new()
		btn.name = get_player_btn_name(player_id)
		btn.text = GameManager.players[player_id].get_player_name()
		btn.disabled = true
		btn.pressed.connect(_on_player_tab_selected.bind(player_id))
		player_list_container.add_child(btn)


func display_player_round(player_id: int) -> void:
	var btn = player_list_container.get_node(get_player_btn_name(player_id))
	if not btn:
		return
	
	btn.disabled = false
	
	
	add_sentence_panel(player_id, 0)


func get_player_btn_name(player_id: int) -> String:
	return str(player_id)


func _on_player_tab_selected(player_id: int):
	for child in round_history_container.get_children():
		child.queue_free()


func add_sentence_panel(player_id: int, round: int):
	var player_name = GameManager.players[player_id].get_player_name()
	var sentence = GameManager.sentences[round][player_id]
	
	var sentence_panel = SENTENCE_PANEL.instantiate()
	sentence_panel.username = player_name
	sentence_panel.sentence = sentence
	
	round_history_container.add_child(sentence_panel)
