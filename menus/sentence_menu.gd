extends Control

var DEFAULT_SENTENCES = [
	"Canard à trois pattes",
	"Piège à souris mais pour éléphant",
	"Marius.",
	"Squeezie en slip",
	"Bigflo mais au lit",
	"Un aigle allemand qui a bu beaucoup de bière",
	"Glados (portal) qui est caissière chez Ledli",
	"Un MP2I qui essaye de parler à une fille (stress 100%)",
	"Un MP2I qui fait un date (avec son ordinateur)",
	"Un MP2I qui fait un date (avec son ordinateur)1",
	"Un MP2I qui fait un date (avec son ordinateur)2",
	"Un MP2I qui fait un date (avec son ordinateur)3",
	"Un MP2I qui fait un date (avec son ordinateur)3",
	"Un MP2I qui fait un date (avec son ordinateur)4",
	"Un MP2I qui fait un date (avec son ordinateur)5",
	"Un MP2I qui fait un date (avec son ordinateur)6",
	"Un MP2I qui fait un date (avec son ordinateur)7",
	"Un MP2I qui fait un date (avec son ordinateur)8",
	"Un MP2I qui fait un date (avec son ordinateur)9",
	"Un MP2I qui fait un date (avec son ordinateur)10",
	"Un MP2I qui fait un date (avec son ordinateur)11",
	"Un MP2I qui fait un date (avec son ordinateur)12",
	"Un MP2I qui fait un date (avec son ordinateur)13",
	"Un MP2I qui fait un date (avec son ordinateur)14",
	"Un MP2I qui fait un date (avec son ordinateur)15",
	"Un MP2I qui fait un date (avec son ordinateur)16",
	"Un MP2I qui fait un date (avec son ordinateur)17",
	"Un MP2I qui fait un date (avec son ordinateur)18",
]

@onready var sentence_line_edit: LineEdit = %SentenceLineEdit
@onready var finish_button: Button = %FinishButton
@onready var timer_label: Label = %TimerLabel
@onready var timer_label_text: String = timer_label.text
@onready var timer: Timer = $Timer

var players_ready: Array[int] = []


func _ready() -> void:
	randomize()
	DEFAULT_SENTENCES.shuffle()
	sentence_line_edit.placeholder_text = DEFAULT_SENTENCES[0]
	_on_finish_button_toggled(false)
	
	GameManager.all_sentences_received.connect(_on_all_sentences_received)

func _process(delta: float) -> void:
	timer_label.text = timer_label_text % timer.time_left

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

@rpc("authority", "call_local", "reliable")
func start_drawing():
	var sentence = sentence_line_edit.text
	if sentence.is_empty():
		sentence = sentence_line_edit.placeholder_text
	GameManager.update_sentence.rpc(sentence)


func _on_timer_timeout() -> void:
	if multiplayer.is_server(): # It's the server who start
		start_drawing.rpc()
	
	#TODO: change scene to an afk scene
	$CenterContainer.hide() # TEMPORARY

func _on_all_sentences_received():
	# We can change the scene
	get_tree().change_scene_to_file("res://menus/drawing/drawing_menu.tscn")
