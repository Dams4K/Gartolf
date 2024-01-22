@tool
extends HBoxContainer

signal width_changed(value: float)

@export var min_value: float = 1.0
@export var max_value: float = 25.0
@export var step: float = 5.0
@export var default_value: float = 5.0

func _ready() -> void:
	self.setup_buttons()

func setup_buttons():
	for child in self.get_children():
		child.queue_free()
	
	for i in range(self.min_value, self.max_value, self.step):
		var btn := Button.new()
		btn.name = str(i)
		btn.custom_minimum_size = Vector2.ONE * 64
		btn.size_flags_horizontal = 6
		btn.pressed.connect(_on_btn_pressed.bind(i))
		
		self.add_child(btn)

func _on_btn_pressed(width: float):
	width_changed.emit(width)
