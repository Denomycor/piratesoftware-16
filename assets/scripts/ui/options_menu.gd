class_name OptionsMenu extends Node


@onready var ui_slider: Slider = %UISizeSlider
@onready var ui_label: Label = %UISizeLabel
@onready var back_button: Button = %back

func _ready() -> void:
	ui_slider.value = GameOptions.ui_scale * 100.0
	ui_label.text = str(GameOptions.ui_scale * 100)
	
	ui_slider.value_changed.connect(_on_ui_slider_value_changed)

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


func _on_ui_slider_value_changed(value: float) -> void:
	GameOptions.change_ui_scale(value)
	ui_label.text = str(value)
