extends GridContainer

signal tool_changed(tool_name)

@export var current_tool: DrawingSpace.TOOLS = DrawingSpace.TOOLS.BRUSH

func _ready() -> void:
	for key in DrawingSpace.TOOLS.keys():
		var btn = Button.new()
		btn.name = key
		btn.custom_minimum_size = Vector2.ONE * 64
		btn.pressed.connect(_on_change_tool_btn_pressed.bind(key))
		btn.icon = load("res://assets/textures/icons/%s.png" % key.to_lower())
		add_child(btn)

func _on_change_tool_btn_pressed(tool_name: String):
	tool_changed.emit(tool_name)
