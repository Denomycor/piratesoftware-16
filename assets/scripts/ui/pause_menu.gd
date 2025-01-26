class_name PauseMenu extends CanvasLayer

signal quit_level

@onready var tab_container := $TabContainer

func _ready() -> void:
	%resume.pressed.connect(toggle_pause_menu)
	%quit.pressed.connect(quit_level.emit)
	%back.pressed.connect(func(): tab_container.current_tab = 0)
	%options.pressed.connect(func(): tab_container.current_tab = 1)
	%window_mode.pressed.connect(toggle_fullscreen)

	if GameOptions.is_fullscreen:
		%window_mode.text = "Windowed"
	else:
		%window_mode.text = "Fullscreen"


func _input(event: InputEvent) -> void:
	if(event is InputEventKey):
		var e := event as InputEventKey
		if(e.get_keycode_with_modifiers() == KEY_ESCAPE && e.pressed):
			toggle_pause_menu()


func toggle_pause_menu() -> void:
	visible = !visible
	get_tree().paused = visible

func toggle_fullscreen() -> void:
	if not GameOptions.is_fullscreen:
		GameOptions.is_fullscreen = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		%window_mode.text = "Windowed"
	else:
		GameOptions.is_fullscreen = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		%window_mode.text = "Fullscreen"
