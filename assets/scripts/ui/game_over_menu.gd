class_name GameOverMenu extends CanvasLayer

signal quit_level

func _ready() -> void:
	visible = false
	%quit.pressed.connect(quit_level.emit)

func show_game_over_menu() -> void:
	visible = true

