extends Control

# load gif exporter module
const GIFExporter = preload("res://gdgifexporter/exporter.gd")
# load quantization module that you want to use
const MedianCutQuantization = preload("res://gdgifexporter/quantization/median_cut.gd")
const GIF_FRAME_TIME = 1

const DISPLAY_SPEED = 2
const SENTENCE_PANEL: PackedScene = preload("res://menus/end_menu/sentence_panel.tscn")
const DRAWING_PANEL: PackedScene = preload("res://menus/end_menu/drawing_panel.tscn")

@onready var player_list_container: VBoxContainer = %PlayerListContainer
@onready var round_history_container: VBoxContainer = %RoundHistoryContainer
@onready var next_button: Button = %NextButton

var last_player_displayed: int = -1

## Current tab
var player_tab: int

func _ready() -> void:
	next_button.visible = multiplayer.is_server()
	
	create_player_buttons()
	if len(GameManager.players_order) > 0:
		_on_next_button_pressed()

func create_player_buttons():
	for player_id in GameManager.players_order:
		var btn = Button.new()
		btn.name = get_player_btn_name(player_id)
		btn.text = GameManager.players[player_id].get_player_name()
		btn.disabled = true
		btn.pressed.connect(_on_player_tab_selected.bind(player_id))
		player_list_container.add_child(btn)


@rpc("authority", "call_local", "reliable")
func display_player_round(player_id: int, stylized_show: bool = false) -> void:
	for child in round_history_container.get_children():
		child.queue_free()
	
	var idx = GameManager.players_order.find(player_id)
	if idx > last_player_displayed:
		last_player_displayed = idx
	
	var btn = player_list_container.get_node(get_player_btn_name(player_id))
	if not btn:
		return
	
	btn.disabled = false
	
	var images: Array = []
	var order_position = GameManager.players_order.find(player_id)
	
	var total_sequence = GameManager.get_total_sequence(order_position)
	
	var dislaye_speed = DISPLAY_SPEED * int(stylized_show) # 0 is stylized_show is false
	for i in range(len(total_sequence)):
		var data = total_sequence[i]
		if data.has("sentence"):
			add_sentence_panel(data.player_id, data.sentence, i*dislaye_speed)
		if data.has("drawing"):
			add_drawing_panel(data.player_id, data.drawing, i*dislaye_speed)


func create_gif(images, path):
	if len(images) > 0:
		var fi: Image = images[0]
		fi.convert(Image.FORMAT_RGBA8)
		var exporter = GIFExporter.new(fi.get_width(), fi.get_height())
		for image in images:
			image.convert(Image.FORMAT_RGBA8)
			exporter.add_frame(image, GIF_FRAME_TIME, MedianCutQuantization)
		
		var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		# save data stream into file
		file.store_buffer(exporter.export_file_data())
		# close the file
		file.close()


func get_player_btn_name(player_id: int) -> String:
	return str(player_id)


func _on_player_tab_selected(player_id: int):
	player_tab = player_id
	display_player_round(player_id)


func add_sentence_panel(player_id: int, sentence: String, stylized_show_time: int):
	var player_name = GameManager.players[player_id].get_player_name()
	var sentence_panel = SENTENCE_PANEL.instantiate()
	sentence_panel.username = player_name
	sentence_panel.sentence = sentence
	sentence_panel.stylized_show_time = stylized_show_time
	
	round_history_container.add_child(sentence_panel)


func add_drawing_panel(player_id: int, drawing: Texture, stylized_show_time: int) -> Image:
	var player_name = GameManager.players[player_id].get_player_name()
	
	var drawing_panel = DRAWING_PANEL.instantiate()
	drawing_panel.username = player_name
	drawing_panel.drawing = drawing
	drawing_panel.stylized_show_time = stylized_show_time
	
	round_history_container.add_child(drawing_panel)
	
	return drawing.get_image()


func _on_next_button_pressed() -> void:
	if not multiplayer.is_server():
		return
	
	if last_player_displayed+1 < len(GameManager.players_order):
		display_player_round.rpc(GameManager.players_order[last_player_displayed+1], true)


func _on_download_gif_button_pressed() -> void:
	var player_idx = GameManager.players_order.find(player_tab)
	var drawings_sequence = GameManager.get_drawings_sequence(player_idx)
	var images = []
	for drawing_sequence in drawings_sequence:
		var drawing = drawing_sequence["drawing"]
		drawing.get_image().save_png(OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS).path_join("test.png"))
		images.append(drawing.get_image())
	
	var download_gif = create_gif.bind(images, OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS).path_join("%s-%s.gif" % [Time.get_unix_time_from_system(), player_tab]))
	var thread = Thread.new()
	thread.start(download_gif)
