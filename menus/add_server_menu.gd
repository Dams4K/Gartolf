extends Control

@onready var address_line_edit: LineEdit = %AddressLineEdit
@onready var port_line_edit: LineEdit = %PortLineEdit
@onready var error_label: Label = %ErrorLabel

var custom_servers: CustomServers = CustomServers.setup()

func _on_add_button_pressed() -> void:
	var address: String = address_line_edit.text
	var port: String = port_line_edit.text
	if address.is_empty() or port.is_empty():
		error_label.text = "Tu dois indiquer l'adresse et le port du serveur"
	elif port != str(port.to_int()):
		error_label.text = "Le port ne doit contenir que des chiffres"
	else: # Everything is okay (i guess?)
		# Add server
		custom_servers.add_server(address, port.to_int())
		
		# Go back to the main menu
		exit()


func _on_cancel_button_pressed() -> void:
	exit()

func exit():
	get_tree().change_scene_to_file("res://menus/main_menu/main_menu.tscn")
