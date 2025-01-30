class_name PauseMenu extends CanvasLayer

signal quit_level

@onready var tab_container := $TabContainer
@onready var options_menu: OptionsMenu = $TabContainer/OptionsMenu
func _ready() -> void:
	%resume.pressed.connect(func():
		toggle_pause_menu()
		$click.play()
	)
	%quit.pressed.connect(func():
		quit_level.emit()
		$click.play()
	)
	%options.pressed.connect(func(): 
		tab_container.current_tab = 1
		$click.play()
	)
	options_menu.back_button.pressed.connect(func(): 
		tab_container.current_tab = 0
		$click.play()
	)

func _input(event: InputEvent) -> void:
	if (event is InputEventKey):
		var e := event as InputEventKey
		if (e.get_keycode_with_modifiers() == KEY_ESCAPE && e.pressed):
			toggle_pause_menu()


func toggle_pause_menu() -> void:
	visible = !visible
	get_tree().paused = visible