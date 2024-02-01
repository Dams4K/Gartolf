extends Control

# load gif exporter module
const GIFExporter = preload("res://gdgifexporter/exporter.gd")
# load quantization module that you want to use
const MedianCutQuantization = preload("res://gdgifexporter/quantization/median_cut.gd")
const GIF_FRAME_TIME = 1

const DISPLAY_SPEED = 6
const SENTENCE_PANEL: PackedScene = preload("res://menus/end_menu/sentence_panel.tscn")
const DRAWING_PANEL: PackedScene = preload("res://menus/end_menu/drawing_panel.tscn")

@onready var player_list_container: VBoxContainer = %PlayerListContainer
@onready var round_history_container: VBoxContainer = %RoundHistoryContainer

func _ready() -> void:
	create_player_buttons()
	display_player_round(GameManager.players_order[0], true)

func create_player_buttons():
	for player_id in GameManager.players_order:
		var btn = Button.new()
		btn.name = get_player_btn_name(player_id)
		btn.text = GameManager.players[player_id].get_player_name()
		#btn.disabled = true
		btn.pressed.connect(_on_player_tab_selected.bind(player_id))
		player_list_container.add_child(btn)


func display_player_round(player_id: int, stylized_show: bool = false) -> void:
	var btn = player_list_container.get_node(get_player_btn_name(player_id))
	if not btn:
		return
	
	btn.disabled = false
	
	var images: Array = []
	var order_position = GameManager.players_order.find(player_id)
	for round in range(GameManager.current_round+1):
		add_sentence_panel(order_position, round, round*DISPLAY_SPEED)
		if round < len(GameManager.drawings):
			var img = add_drawing_panel(order_position-1, round, (round+0.5)*DISPLAY_SPEED)
			img.convert(Image.FORMAT_RGBA8)
			images.append(img)
		order_position += 1
	
	var thread = Thread.new()
	thread.start(create_gif.bind(images, player_id))


func create_gif(images, player_id):
	if len(images) > 0:
		var fi: Image = images[0]
		var exporter = GIFExporter.new(fi.get_width(), fi.get_height())
		for image in images:
			exporter.add_frame(image, GIF_FRAME_TIME, MedianCutQuantization)
		
		var file: FileAccess = FileAccess.open("user://result-%s.gif" % player_id, FileAccess.WRITE)
		# save data stream into file
		file.store_buffer(exporter.export_file_data())
		# close the file
		file.close()


func get_player_btn_name(player_id: int) -> String:
	return str(player_id)


func _on_player_tab_selected(player_id: int):
	for child in round_history_container.get_children():
		child.queue_free()
	display_player_round(player_id)


func add_sentence_panel(order_position: int, round: int, stylized_show_time: int):
	var player_id = GameManager.players_order[(order_position+round)%len(GameManager.players)]
	var player_name = GameManager.players[player_id].get_player_name()
	var sentence = GameManager.sentences[round][player_id]
	
	var sentence_panel = SENTENCE_PANEL.instantiate()
	sentence_panel.username = player_name
	sentence_panel.sentence = sentence
	sentence_panel.stylized_show_time = stylized_show_time
	
	round_history_container.add_child(sentence_panel)


func add_drawing_panel(order_position: int, round: int, stylized_show_time: int) -> Image:
	var player_id = GameManager.players_order[(order_position+round)%len(GameManager.players)]
	var player_name = GameManager.players[player_id].get_player_name()
	var drawing: Texture = GameManager.get_drawing(round, player_id)
	
	var drawing_panel = DRAWING_PANEL.instantiate()
	drawing_panel.username = player_name
	drawing_panel.drawing = drawing
	drawing_panel.stylized_show_time = stylized_show_time
	
	round_history_container.add_child(drawing_panel)
	
	return drawing.get_image()
