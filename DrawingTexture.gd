extends TextureRect

var SCREEN_SIZE = Vector2(
	ProjectSettings.get("display/window/size/viewport_width"),
	ProjectSettings.get("display/window/size/viewport_height")
)

@onready var drawing_viewport: SubViewport = $DrawingViewport
@onready var camera_2d: Camera2D = $DrawingViewport/Camera2D

func _ready() -> void:
	drawing_viewport.size = get_viewport_rect().size


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		save_drawing()
	queue_redraw()

#TODO: TMP FUNCTION
func save_drawing():
	var drawing: Texture2D = drawing_viewport.get_texture()
	drawing.get_image().save_png("res://drawing.png")

func _on_gui_input(event: InputEvent) -> void:
	event.position -= size/2
	event.position *= 2
	drawing_viewport.push_input(event)
