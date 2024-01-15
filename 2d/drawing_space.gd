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
@export var background_color := Color.BLACK: set = set_background_color
@export var color := Color.BLACK

@export var gap := 3.0

var current_line
var history_backward_index = 0

@onready var lines: Node2D = $Lines
@onready var background_color_rect: ColorRect = %BackgroundColorRect


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if current_tool in [TOOLS.RECTANGLE_FILLED]:
				current_line 
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
				lines.add_child(current_line)
				
				current_line.add_point(event.position)
				if current_tool == TOOLS.LINE:
					current_line.add_point(event.position)
				
				if current_tool in [TOOLS.RECTANGLE_EMPTY]:
					current_line.add_point(event.position)
					current_line.add_point(event.position)
					current_line.add_point(event.position)
					current_line.add_point(event.position)
				
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
				pass

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

func set_background_color(value: Color):
	background_color = color
	background_color_rect.color = color
