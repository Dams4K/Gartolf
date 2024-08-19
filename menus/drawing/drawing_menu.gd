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
@onready var finish_button: Button = %FinishButton

var current_color: Color = Color.BLACK
var current_tool: int = DrawingSpace.TOOLS.BRUSH
var current_opacity: float = 1.0

var players_ready: Array[int] = []

func _ready() -> void:
	timer.wait_time = ProjectSettings.get("game/settings/drawing_time")
	timer.start()
	
	GameManager.all_drawings_received.connect(_on_all_drawings_received)
	drawing_space.current_color = current_color
	
	sentence_label.text = GameManager.get_our_sentence()
	
	_on_width_container_width_changed(width_container.default_value)
	_on_finish_button_toggled(false)

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
		end_drawing.rpc()
	
	#TODO: find a better way to keep the player from drawing
	$HBoxContainer.hide()

func _on_all_drawings_received():
	if GameManager.current_round == round(len(GameManager.players) / 2):
		GameManager.end()
	else:
		GameManager.current_round += 1
		get_tree().change_scene_to_file("res://menus/sentence_menu.tscn")


func _on_opacity_slider_value_changed(value: float) -> void:
	current_opacity = value
	drawing_space.current_opacity = value


func _on_width_container_width_changed(value: float) -> void:
	drawing_space.width = value


func _on_finish_button_toggled(toggled_on: bool) -> void:
	finish_button.text = "Terminé" if !toggled_on else "Modifier"
	
	toggle_ready.rpc(toggled_on)

@rpc("any_peer", "call_local", "reliable")
func toggle_ready(is_ready: bool):
	var id = multiplayer.get_remote_sender_id()
	
	if not is_ready and id in players_ready:
		players_ready.erase(id)
	elif is_ready:
		players_ready.append(id)
	
	if multiplayer.is_server() and len(players_ready) == len(GameManager.players):
		end_drawing.rpc()
