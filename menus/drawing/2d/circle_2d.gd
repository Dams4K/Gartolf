@tool
class_name Circle2D
extends Node2D

@export_range(0, 100, 0.05, "or_greater", "hide_slider", "suffix:px") var radius := 5.0 : set = set_radius
@export_range(1, 100, 0.05, "or_greater", "hide_slider", "suffix:px") var width := 1.0 : set = set_width
@export var default_color := Color.BLACK : set = set_default_color
@export var filled := false : set = set_filled

func _draw() -> void:
	if filled:
		draw_circle(Vector2.ZERO, radius, default_color)
	else:
		draw_arc(Vector2.ZERO, radius, 0, 3*PI, 128, default_color, width, true)

func set_radius(value: float):
	radius = value
	queue_redraw()

func set_width(value: float):
	width = value
	queue_redraw()

func set_default_color(value: Color):
	default_color = value
	queue_redraw()

func set_filled(value: bool):
	filled = value
	queue_redraw()
