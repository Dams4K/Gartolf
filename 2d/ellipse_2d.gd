@tool
class_name Ellipse2D
extends Node2D

enum ANCHOR {
	TOP_LEFT,
	CENTER
}

@export var anchor: ANCHOR = ANCHOR.TOP_LEFT : set = set_anchor
@export_range(0.05, 100, 0.05, "or_greater", "hide_slider", "suffix:px") var width := 1.0 : set = set_width
@export var default_color := Color.BLACK : set = set_default_color
@export var filled := false : set = set_filled
@export_range(1, 360, 1, "suffix:deg") var step := 10.0 : set = set_step

@export var ellipse_scale: Vector2 = Vector2.ONE : set = set_ellipse_scale

var line_2d: Line2D
var polygon_2d: Polygon2D

func _ready() -> void:
	line_2d = Line2D.new()
	polygon_2d = Polygon2D.new()
	line_2d.joint_mode = Line2D.LINE_JOINT_ROUND
	line_2d.begin_cap_mode = Line2D.LINE_CAP_ROUND
	line_2d.end_cap_mode = Line2D.LINE_CAP_ROUND
	
	add_child(line_2d)
	add_child(polygon_2d)
	
	set_default_color(default_color)
	set_width(width)

func update_ellipse() -> void:
	if not line_2d:
		return
	
	var points: Array[Vector2] = []
	
	var t = 0
	
	var h = 0
	var k = 0
	
	if anchor == ANCHOR.TOP_LEFT:
		h = ellipse_scale.x
		k = ellipse_scale.y
	var r_step = step*PI/360
	
	var last_x = null
	var last_y = null
	
	while t < 2*PI:
		var x = h - ellipse_scale.x * cos(t)
		var y = k - ellipse_scale.y * sin(t)
		points.append(Vector2(x, y))
		last_x = x
		last_y = y
		t += r_step
	
	if filled:
		polygon_2d.polygon = points
		polygon_2d.show()
		line_2d.hide()
	else:
		points.append(points[0])
		line_2d.points = points
		line_2d.show()
		polygon_2d.hide()


func set_width(value: float):
	width = value
	if line_2d:
		line_2d.width = width

func set_default_color(value: Color):
	default_color = value
	if line_2d:
		line_2d.default_color = default_color
	if polygon_2d:
		polygon_2d.color = default_color

func set_filled(value: bool):
	filled = value
	update_ellipse()

func set_step(value: float):
	step = value
	update_ellipse()


func set_ellipse_scale(value: Vector2):
	ellipse_scale = value
	update_ellipse()


func set_anchor(value: ANCHOR):
	anchor = value
	update_ellipse()
