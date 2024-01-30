extends Panel

@export var username: String = "Username": set = set_username
@export var drawing: Texture: set = set_drawing

@onready var username_label: Label = %UsernameLabel
@onready var drawing_texture_rect: TextureRect = %DrawingTextureRect


func _ready() -> void:
	set_username(username)
	set_drawing(drawing)


func set_username(value: String):
	username = value
	if username_label:
		username_label.text = " %s" % value


func set_drawing(value: Texture):
	drawing = value
	if drawing_texture_rect:
		drawing_texture_rect.texture = value
