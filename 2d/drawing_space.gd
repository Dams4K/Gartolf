extends Node2D

@onready var lines: Node2D = $Lines

var current_line: Line2D
@export_range(1, 25, 1, "or_greater") var width = 4
@export var color := Color.BLACK

@export var gap := 3.0

var history_backward_index = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			current_line = Line2D.new()
			current_line.default_color = color
			current_line.width = width
			current_line.joint_mode = Line2D.LINE_JOINT_ROUND
			current_line.begin_cap_mode = Line2D.LINE_CAP_ROUND
			current_line.end_cap_mode = Line2D.LINE_CAP_ROUND
			lines.add_child(current_line)
			
			current_line.add_point(event.position)
			
			for i in range(history_backward_index, lines.get_child_count()):
				var child = lines.get_child(i)
				if not child.visible:
					child.queue_free()
		else:
			current_line.add_point(event.position + Vector2.ONE/100) # Monkey patch to create a dot if the mouse haven't moved
			current_line = null
	
	if event is InputEventMouseMotion:
		if current_line:
			if current_line.get_point_position(current_line.get_point_count()-1).distance_to(event.position) > gap:
				current_line.add_point(event.position) #TODO (amélioration): Détecter quand on quitte une ligne droite pour mettre - de points

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
