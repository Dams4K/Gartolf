extends TextureButton

@export var color := Color.BLACK

@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	color_rect.color = color
