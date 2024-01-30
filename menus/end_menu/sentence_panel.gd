extends Panel

@export var username: String = "Username": set = set_username
@export var sentence: String = "blablabla": set = set_sentence


@onready var username_label: Label = %UsernameLabel
@onready var sentence_label: Label = %SentenceLabel


func _ready() -> void:
	set_username(username)
	set_sentence(sentence)


func set_username(value: String) -> void:
	username = value
	if username_label:
		username_label.text = value


func set_sentence(value: String) -> void:
	sentence = value
	if sentence_label:
		sentence_label.text = "  %s" % value
