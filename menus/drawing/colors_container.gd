extends VBoxContainer

const BUTTON = preload("res://menus/drawing/color_button.tscn")
const BUTTON_SIZE := Vector2i(48, 48)
const BUTTON_MATERIAL := preload("res://assets/materials/color_button_theme.tres")

signal color_selected(color)

@export var colors: Array[Color] = []

@onready var grid_container: GridContainer = $GridContainer

func _ready() -> void:
	for color in colors:
		var button = BUTTON.instantiate()
		button.color = color
		button.custom_minimum_size = BUTTON_SIZE
		button.pressed.connect(_on_btn_pressed.bind(button))
		
		grid_container.add_child(button)

func _on_btn_pressed(btn):
	color_selected.emit(btn.color)
