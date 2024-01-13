extends Control
# /!\ mouse_filter need to be set to "ignore"


var SCREEN_SIZE = Vector2(
	ProjectSettings.get("display/window/size/viewport_width"),
	ProjectSettings.get("display/window/size/viewport_height")
)

@onready var drawing_viewport: SubViewport = %DrawingViewport
@onready var drawing_space: Node2D = %DrawingSpace

var current_color: Color = Color.BLACK
var current_tool

func _ready() -> void:
	drawing_space.color = current_color
	drawing_viewport.size = SCREEN_SIZE

func _on_colors_container_color_selected(color) -> void:
	current_color = color
	drawing_space.color = color


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		save_drawing()

#TODO: TMP FUNCTION
func save_drawing():
	var drawing: Texture2D = drawing_viewport.get_texture()
	drawing.get_image().save_png("res://drawing.png")


func _on_drawing_texture_gui_input(event: InputEvent) -> void:
#	event.position -= size/2 # If i have a camera
	event.position *= 2
	drawing_viewport.push_input(event)
