extends VBoxContainer

const BUTTON = preload("res://menus/drawing/color_button.tscn")
const BUTTON_SIZE := Vector2i(48, 48)
const BUTTON_MATERIAL := preload("res://assets/materials/color_button_theme.tres")

signal color_selected(color)

@export var colors: Array[Color] = []

@onready var grid_container: GridContainer = $GridContainer
@onready var color_picker_window: Window = %ColorPickerWindow
@onready var color_picker: ColorPicker = %ColorPicker
@onready var custom_color_button: TextureButton = %CustomColorButton


func _ready() -> void:
	color_picker_window.hide()
	
	for color in colors:
		var button = BUTTON.instantiate()
		button.color = color
		button.custom_minimum_size = BUTTON_SIZE
		button.pressed.connect(_on_btn_pressed.bind(button))
		
		grid_container.add_child(button)

func _on_btn_pressed(btn):
	color_selected.emit(btn.color)


func _on_custom_color_button_pressed() -> void:
	color_picker.color = custom_color_button.color
	color_picker_window.show()


func _on_color_picker_window_close_requested() -> void:
	color_picker_window.hide()


func _on_select_color_button_pressed() -> void:
	color_selected.emit(color_picker.color)
	custom_color_button.color = color_picker.color
	color_picker_window.hide()
