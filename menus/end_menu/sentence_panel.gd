extends Panel

@export var username: String = "Username": set = set_username
@export var sentence: String = "blablabla": set = set_sentence

@onready var v_box_container: VBoxContainer = $VBoxContainer

@onready var username_label: Label = %UsernameLabel
@onready var sentence_label: Label = %SentenceLabel

@onready var show_timer: Timer = $ShowTimer

var stylized_show_time = -1


func _ready() -> void:
	set_username(username)
	set_sentence(sentence)
	
	if stylized_show_time > 0:
		modulate.a = 0
		show_timer.wait_time = stylized_show_time
		show_timer.start()


func set_username(value: String) -> void:
	username = value
	if username_label:
		username_label.text = value


func set_sentence(value: String) -> void:
	sentence = value
	if sentence_label:
		sentence_label.text = "  %s" % value


func _process(delta: float) -> void:
	custom_minimum_size.y = sentence_label.size.y + username_label.size.y + 8


func _on_show_timer_timeout() -> void:
	cool_show()

func cool_show():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
