class_name Tutorial extends CanvasLayer

@onready var timer := $Timer

func _ready() -> void:
	timer.timeout.connect(play.emit)

signal play

func start() -> void:
	visible = true
	timer.start()

func _input(event):
	if event is InputEventKey:
		if event.pressed and (event.keycode == KEY_ESCAPE || event.keycode == KEY_SPACE || event.keycode == KEY_ENTER):
			play.emit()
			timer.stop()
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			play.emit()
			timer.stop()
