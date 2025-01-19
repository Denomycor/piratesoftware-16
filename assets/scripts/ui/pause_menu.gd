class_name PauseMenu extends CanvasLayer


func _ready() -> void:
	%resume.pressed.connect(toggle_pause_menu)
	%quit.pressed.connect(get_parent().quit_level)


func _input(event: InputEvent) -> void:
	if(event is InputEventKey):
		var e := event as InputEventKey
		if(e.get_keycode_with_modifiers() == KEY_ESCAPE && e.pressed):
			toggle_pause_menu()


func toggle_pause_menu() -> void:
	visible = !visible
	get_tree().paused = visible

