class_name MainMenu extends CanvasLayer

@onready var tab_container := $TabContainer

func _ready() -> void:
	%back.pressed.connect(func(): tab_container.current_tab = 0)
	%options.pressed.connect(func(): tab_container.current_tab = 1)
	%window_mode.pressed.connect(toggle_fullscreen)

	if GameOptions.is_fullscreen:
		%window_mode.text = "Windowed"
	else:
		%window_mode.text = "Fullscreen"

func toggle_fullscreen() -> void:
	if not GameOptions.is_fullscreen:
		GameOptions.is_fullscreen = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		%window_mode.text = "Windowed"
	else:
		GameOptions.is_fullscreen = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		%window_mode.text = "Fullscreen"