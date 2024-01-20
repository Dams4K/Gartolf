extends Node2D
class_name DrawingSpace

enum TOOLS {
	BRUSH,
	ERASER,
	LINE,
	RECTANGLE_EMPTY,
	RECTANGLE_FILLED,
	CIRCLE_EMPTY,
	CIRCLE_FILLED
}

@export var current_tool: TOOLS = TOOLS.BRUSH
@export_range(1, 25, 1, "or_greater") var width = 4
@export var current_color := Color.BLACK

@export var gap := 3.0

var current_line: Line2D
var current_polygon: Polygon2D
var current_ellipse: Ellipse2D

var history_backward_index = 0

@onready var lines: Node2D = $Lines

var center_object_pos: Vector2

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# If event.pressed we will create a new line,
		# if not event.pressed we don't want to use the
		# current line anymore
		current_line = null
		current_polygon = null
		current_ellipse = null
	
	match current_tool:
		TOOLS.BRUSH:
			handle_brush(event, current_color, width)
		TOOLS.ERASER:
			handle_brush(event, Color.WHITE, width)
		TOOLS.LINE:
			handle_line(event, current_color, width)
		TOOLS.RECTANGLE_EMPTY:
			handle_rectangle_empty(event, current_color, width)
		TOOLS.RECTANGLE_FILLED:
			handle_rectangle_filled(event, current_color, width)
		TOOLS.CIRCLE_EMPTY:
			handle_ellipse(event, current_color, width, false)
		TOOLS.CIRCLE_FILLED:
			handle_ellipse(event, current_color, width, true)


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_undo"):
		for i in range(lines.get_child_count()-1, -1, -1):
			var child = lines.get_child(i)
			if child.visible:
				child.visible = false
				history_backward_index = i
				break
	elif Input.is_action_just_pressed("ui_redo"):
		for i in range(history_backward_index, lines.get_child_count()):
			var child = lines.get_child(i)
			if not child.visible:
				child.visible = true
				break

func create_line(color: Color, width: int, round: bool = true) -> Line2D:
	var line = Line2D.new()
	line.default_color = color
	line.width = width
	if round:
		line.joint_mode = Line2D.LINE_JOINT_ROUND
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
	else:
		line.joint_mode = Line2D.LINE_JOINT_SHARP
		line.begin_cap_mode = Line2D.LINE_CAP_BOX
		line.end_cap_mode = Line2D.LINE_CAP_BOX
	
	return line

func create_polygon(color: Color) -> Polygon2D:
	var p = Polygon2D.new()
	p.color = color
	return p

# TODO: remove "line" & "a" parameters
func apply_rectangle_transformations(a, line, positions: Array[Vector2]) -> Array[Vector2]:
	if Input.is_key_pressed(KEY_SHIFT):
			var max_axis = abs(a[a.max_axis_index()])
			positions[1] =  center_object_pos + Vector2(max_axis * sign(a.x), 0)
			positions[2] = center_object_pos + a.sign() * max_axis
			positions[3] = center_object_pos + Vector2(0, max_axis * sign(a.y))
		
	if Input.is_key_pressed(KEY_CTRL):
		line.position = (positions[0]-positions[2])/2
	else:
		line.position = Vector2.ONE
	
	return positions


func handle_rectangle_empty(event: InputEvent, color: Color, width: int):
	if event is InputEventMouseButton:
		if event.pressed:
			center_object_pos = event.position
			
			current_line = create_line(color, width, false)
			for i in range(5):
				current_line.add_point(event.position)
			lines.add_child(current_line)
	elif event is InputEventMouseMotion and current_line:
		var new_positions: Array[Vector2] = [
			center_object_pos,
			Vector2(event.position.x, center_object_pos.y),
			event.position,
			Vector2(center_object_pos.x, event.position.y),
			center_object_pos
		]
		
		var a: Vector2 = event.position-center_object_pos
		new_positions = apply_rectangle_transformations(a, current_line, new_positions)
		
		# Apply new positions
		for i in range(len(new_positions)):
			current_line.set_point_position(i, new_positions[i])

func handle_rectangle_filled(event: InputEvent, color: Color, width: int):
	if event is InputEventMouseButton:
		if event.pressed:
			center_object_pos = event.position
			current_polygon = create_polygon(color)
			
			var polygon = []
			for i in range(4):
				polygon.append(event.position)
			current_polygon.polygon = polygon
			lines.add_child(current_polygon)
			
	elif event is InputEventMouseMotion and current_polygon:
		var polygon: Array[Vector2] = [
			center_object_pos,
			Vector2(event.position.x, center_object_pos.y),
			event.position,
			Vector2(center_object_pos.x, event.position.y),
			center_object_pos
		]
		
		var a: Vector2 = event.position-center_object_pos
		polygon = apply_rectangle_transformations(a, current_polygon, polygon)
		
		# Apply new positions
		for i in range(len(polygon)):
			current_polygon.polygon = polygon

func handle_ellipse(event: InputEvent, color: Color, width: float, filled: bool):
	if event is InputEventMouseButton:
		if event.pressed:
			center_object_pos = event.position
			current_ellipse = Ellipse2D.new()
			current_ellipse.position = center_object_pos
			current_ellipse.default_color = color
			current_ellipse.width = width
			current_ellipse.filled = filled
			
			lines.add_child(current_ellipse)
	
	elif event is InputEventMouseMotion and current_ellipse:
		current_ellipse.ellipse_scale = (event.position - center_object_pos)/2
		
		if Input.is_key_pressed(KEY_SHIFT):
			current_ellipse.ellipse_scale = Vector2.ONE * abs(current_ellipse.ellipse_scale[current_ellipse.ellipse_scale.max_axis_index()])  * (event.position - center_object_pos).sign()
			print(current_ellipse.ellipse_scale)
		
		if Input.is_key_pressed(KEY_CTRL):
			current_ellipse.anchor = current_ellipse.ANCHOR.CENTER
			current_ellipse.ellipse_scale *= 2
		else:
			current_ellipse.anchor = current_ellipse.ANCHOR.TOP_LEFT

func handle_brush(event: InputEventMouse, color: Color, width: int, gap: int = 5):
	if event is InputEventMouseButton:
		if event.pressed:
			current_line = create_line(color, width)
			current_line.add_point(event.position)
			lines.add_child(current_line)
			current_line.add_point(event.position + Vector2.ONE/100)
	elif event is InputEventMouseMotion and current_line:
		if current_line.get_point_position(current_line.get_point_count()-1).distance_to(event.position) > gap:
			current_line.add_point(event.position) #TODO (amélioration): Détecter quand on quitte une ligne droite pour mettre - de points


func handle_line(event, color, width):
	if event is InputEventMouseButton:
		if event.pressed:
			current_line = create_line(color, width)
			for i in range(2):
				current_line.add_point(event.position)
			lines.add_child(current_line)
	
	elif event is InputEventMouseMotion and current_line:
		current_line.set_point_position(1, event.position)
