extends Control

const DEFAULT_SENTENCES = [
	"Canard à trois pattes",
	"Piège à souris mais pour éléphant",
	"Marius.",
	"Squeezie en slip",
	"Bigflo mais au lit",
	"Un aigle allemand qui a bu beaucoup de bière",
	"Glados (portal) qui est caissière chez Ledli",
	"Un MP2I qui essaye de parler à une fille (stress 100%)",
	"Un MP2I qui fait un date (avec son ordinateur)"
]

@onready var sentence_line_edit: LineEdit = %SentenceLineEdit
@onready var finish_button: Button = %FinishButton

var players_ready: Array[int] = []

func _ready() -> void:
	randomize()
	_on_finish_button_toggled(false)

func _on_finish_button_toggled(button_pressed: bool) -> void:
	sentence_line_edit.editable = !button_pressed
	finish_button.text = "Terminé" if !button_pressed else "Modifier"
	
	if button_pressed:
		set_ready.rpc()

@rpc("any_peer", "call_local", "reliable")
func set_ready():
	var id = multiplayer.get_remote_sender_id()
	
	if id in players_ready:
		players_ready.erase(id)
	else:
		players_ready.append(id)
	
	if multiplayer.is_server() and len(players_ready) == len(GameManager.players):
		start_drawing.rpc()

@rpc("call_local", "reliable")
func start_drawing():
	GameManager.update_sentence.rpc(sentence_line_edit.text, 0)
	get_tree().change_scene_to_file("res://menus/drawing/drawing_menu.tscn")
