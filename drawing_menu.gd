extends Control
# /!\ mouse_filter need to be set to "ignore"

@onready var drawing_space: Node2D = %DrawingSpace

func _on_colors_container_color_selected(color) -> void:
	drawing_space.color = color
