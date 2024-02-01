extends Panel

@export var username: String = "Username": set = set_username
@export var drawing: Texture: set = set_drawing

@onready var username_label: Label = %UsernameLabel
@onready var drawing_texture_rect: TextureRect = %DrawingTextureRect

@onready var show_timer: Timer = $ShowTimer

var stylized_show_time = -1

func _ready() -> void:
	set_username(username)
	set_drawing(drawing)
	
	if stylized_show_time > 0:
		modulate.a = 0
		show_timer.wait_time = stylized_show_time
		show_timer.start()


func set_username(value: String):
	username = value
	if username_label:
		username_label.text = " %s" % value


func set_drawing(value: Texture):
	drawing = value
	if drawing_texture_rect:
		drawing_texture_rect.texture = value


func _on_show_timer_timeout() -> void:
	cool_show()

func cool_show():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
