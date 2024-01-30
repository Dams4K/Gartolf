extends Control
# /!\ mouse_filter need to be set to "ignore"

var SCREEN_SIZE = Vector2(
	ProjectSettings.get("display/window/size/viewport_width"),
	ProjectSettings.get("display/window/size/viewport_height")
)

@onready var drawing_viewport: SubViewport = %DrawingViewport
@onready var drawing_space: DrawingSpace = %DrawingSpace
@onready var drawing_texture: TextureRect = $HBoxContainer/VBoxContainer/DrawingTexture
@onready var sentence_label: Label = %SentenceLabel
@onready var timer_label: Label = %TimerLabel
@onready var timer_label_text: String = timer_label.text
@onready var timer: Timer = $Timer
@onready var width_container: HBoxContainer = %WidthContainer

var current_color: Color = Color.BLACK
var current_tool: int = DrawingSpace.TOOLS.BRUSH
var current_opacity: float = 1.0

func _ready() -> void:
	GameManager.all_drawings_received.connect(_on_all_drawings_received)
	#print(SCREEN_SIZE)
	drawing_space.current_color = current_color
	#drawing_viewport.size = SCREEN_SIZE
	
	sentence_label.text = GameManager.get_our_sentence()
	
	_on_width_container_width_changed(width_container.default_value)

func _on_colors_container_color_selected(color) -> void:
	current_color = color
	drawing_space.current_color = color


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		save_drawing()
	
	timer_label.text = timer_label_text % timer.time_left

#TODO: TMP FUNCTION
func save_drawing():
	var drawing: Texture2D = drawing_viewport.get_texture()
	drawing.get_image().save_png("res://drawing.png")


func _on_drawing_texture_gui_input(event: InputEvent) -> void:
	event.position *= Vector2(drawing_viewport.size)/drawing_texture.size
	drawing_viewport.push_input(event)


func _on_tools_container_tool_changed(tool_name) -> void:
	drawing_space.current_tool = DrawingSpace.TOOLS.get(tool_name)


@rpc("authority", "call_local", "reliable")
func end_drawing():
	var drawing: ViewportTexture = drawing_viewport.get_texture()
	var image: Image = drawing.get_image()
	var buffer: PackedByteArray = image.save_png_to_buffer()
	
	GameManager.update_drawing.rpc(buffer)


func _on_timer_timeout() -> void:
	if multiplayer.is_server(): # It's the server who start
		#TODO: Find another way
		printt(GameManager.current_round, len(GameManager.players) % 2)
		if GameManager.current_round == len(GameManager.players) % 2:
			GameManager.end()
		else:
			end_drawing.rpc()
	
	#TODO: find a better way to keep the player from drawing
	$HBoxContainer.hide()

func _on_all_drawings_received():
	GameManager.current_round += 1
	get_tree().change_scene_to_file("res://menus/sentence_menu.tscn")


func _on_opacity_slider_value_changed(value: float) -> void:
	current_opacity = value
	drawing_space.current_opacity = value


func _on_width_container_width_changed(value: float) -> void:
	drawing_space.width = value
