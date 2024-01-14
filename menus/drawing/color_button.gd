extends TextureButton

@export var color := Color.BLACK: set = set_color

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.color = color

func set_color(value: Color):
	color = value
	if color_rect:
		color_rect.color = value
