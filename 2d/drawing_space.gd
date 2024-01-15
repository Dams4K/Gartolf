extends Node2D


enum TOOLS {
	BRUSH,
	ERASER,
	LINE,
	RECTANGLE_EMPTY,
	RECTANGLE_FILLED
}

@export var current_tool: TOOLS = TOOLS.BRUSH
@export_range(1, 25, 1, "or_greater") var width = 4
@export var color := Color.BLACK

@export var gap := 3.0

var current_line
var history_backward_index = 0

@onready var lines: Node2D = $Lines

var center_object_pos: Vector2

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		# If event.pressed we will create a new line,
		# if not event.pressed we don't want to use the
		# current line anymore
		current_line = null
	
	match current_tool:
		TOOLS.BRUSH:
			handle_brush(event, color, width)
		TOOLS.ERASER:
			handle_brush(event, Color.WHITE, width)
		TOOLS.RECTANGLE_EMPTY:
			handle_rectangle_empty(event, color, width)
	
	return
	if event is InputEventMouseButton:
		if event.pressed:
			if current_tool in [TOOLS.RECTANGLE_FILLED]:
				current_line = Polygon2D.new()
				current_line.color = color
				var polygon = []
				polygon.append(event.position)
				polygon.append(event.position)
				polygon.append(event.position)
				polygon.append(event.position)
				current_line.polygon = polygon
			else:
				current_line = Line2D.new()
				current_line.default_color = color
				if current_tool == TOOLS.ERASER:
					# Force white for the eraser
					current_line.default_color = Color.WHITE
					
				current_line.width = width
				current_line.joint_mode = Line2D.LINE_JOINT_ROUND
				current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
				current_line.end_cap_mode = Line2D.LINE_CAP_ROUND
				
				current_line.add_point(event.position)
				if current_tool == TOOLS.LINE:
					current_line.add_point(event.position)
				
				if current_tool in [TOOLS.RECTANGLE_EMPTY]:
					current_line.add_point(event.position)
					current_line.add_point(event.position)
					current_line.add_point(event.position)
					current_line.add_point(event.position)
			
			lines.add_child(current_line)
			for i in range(history_backward_index, lines.get_child_count()):
				var child = lines.get_child(i)
				if not child.visible:
					child.queue_free()
		else:
			if current_tool in [TOOLS.BRUSH, TOOLS.ERASER]:
				current_line.add_point(event.position + Vector2.ONE/100) # Monkey patch to create a dot if the mouse haven't moved
			
			current_line = null
	
	if event is InputEventMouseMotion:
		if current_line:
			# For the eraser and brush only 
			if current_tool in [TOOLS.ERASER, TOOLS.BRUSH]:
				
				if current_line.get_point_position(current_line.get_point_count()-1).distance_to(event.position) > gap:
					current_line.add_point(event.position) #TODO (amélioration): Détecter quand on quitte une ligne droite pour mettre - de points
			
			# If we are using the line tool
			if current_tool == TOOLS.LINE:
				current_line.set_point_position(1, event.position)
				
			if current_tool == TOOLS.RECTANGLE_EMPTY:
				# POINT TOP LEFT
				var ptr_pos = current_line.get_point_position(1)
				var pbl_pos = current_line.get_point_position(3)
				current_line.set_point_position(1, Vector2(event.position.x, ptr_pos.y))
				current_line.set_point_position(2, event.position)
				current_line.set_point_position(3, Vector2(pbl_pos.x, event.position.y))
			
			if current_tool == TOOLS.RECTANGLE_FILLED:
				var ptr_pos = current_line.polygon[1]
				var pbl_pos = current_line.polygon[3]
				current_line.polygon[1] = Vector2(event.position.x, ptr_pos.y)
				current_line.polygon[2] = event.position
				current_line.polygon[3] = Vector2(pbl_pos.x, event.position.y)

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

func create_polygon() -> Polygon2D:
	return Polygon2D.new()

func handle_rectangle(color: Color, filled: bool):
	pass

func handle_rectangle_empty(event: InputEvent, color: Color, width: int):
	if event is InputEventMouseButton:
		if event.pressed:
			center_object_pos = event.position
			
			current_line = create_line(color, width, false)
			for i in range(5):
				current_line.add_point(event.position)
			lines.add_child(current_line)
	elif event is InputEventMouseMotion and current_line:
		var ptr_pos = current_line.get_point_position(1)
		var pbl_pos = current_line.get_point_position(3)
		
		var a: Vector2 = event.position-center_object_pos
		
		var new_positions: Array[Vector2] = [
			center_object_pos,
			Vector2(event.position.x, center_object_pos.y),
			event.position,
			Vector2(center_object_pos.x, event.position.y),
			center_object_pos
		]
		
		if Input.is_key_pressed(KEY_SHIFT):
			var max_axis = abs(a[a.max_axis_index()])
			new_positions[1] =  center_object_pos + Vector2(max_axis * sign(a.x), 0)
			new_positions[2] = center_object_pos + a.sign() * max_axis
			new_positions[3] = center_object_pos + Vector2(0, max_axis * sign(a.y))
		
		if Input.is_key_pressed(KEY_CTRL):
			current_line.position = (new_positions[0]-new_positions[2])/2
		else:
			current_line.position = Vector2.ONE
		
		# Apply new positions
		for i in range(len(new_positions)):
			current_line.set_point_position(i, new_positions[i])

func handle_rectangle_filled(color: Color):
	pass

func handle_brush(event: InputEventMouse, color: Color, width: int, gap: int = 5):
	if event is InputEventMouseButton:
		if event.pressed:
			current_line = create_line(color, width)
			current_line.add_point(event.position)
			lines.add_child(current_line)
	elif event is InputEventMouseMotion and current_line:
		if current_line.get_point_position(current_line.get_point_count()-1).distance_to(event.position) > gap:
			current_line.add_point(event.position) #TODO (amélioration): Détecter quand on quitte une ligne droite pour mettre - de points
