extends Control

@onready var orange_player: AnimationPlayer = $OrangePlayer
@onready var purple_player: AnimationPlayer = $PurplePlayer
@onready var dot_player: AnimationPlayer = $DotPlayer

func _ready() -> void:
	orange_player.play("SlowBlink")
	await get_tree().create_timer(2).timeout
	purple_player.play("SlowBlink")
	await get_tree().create_timer(2).timeout
	dot_player.play("SlowBlink")
