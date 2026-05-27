class_name Tutorial extends CanvasLayer

@onready var timer := $Timer
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var continue_label: Label = $ContinueLabel

signal play

## Set to true once the loading is complete; blocks all skip paths until then.
var _loading_done := false
## Set to true once the timer fires or the user provides a skip input.
var _wants_to_skip := false
## Guards against emitting play more than once.
var _played := false


func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.85, 0.1, 0.1)
	progress_bar.add_theme_stylebox_override("fill", style)


func start() -> void:
	visible = true
	_loading_done = false
	_wants_to_skip = false
	_played = false
	progress_bar.value = 0.0
	continue_label.visible = false
	timer.start()


## Called by Game when loading + shader warmup are complete.
func enable_skip() -> void:
	_loading_done = true
	continue_label.visible = true
	_maybe_proceed()


## Called by Game to forward loading progress (0–100).
func set_progress(value: float) -> void:
	progress_bar.value = value


func _on_timer_timeout() -> void:
	_wants_to_skip = true
	_maybe_proceed()


func _maybe_proceed() -> void:
	if _loading_done and _wants_to_skip and not _played:
		_played = true
		play.emit()


func _input(event: InputEvent) -> void:
	if not _loading_done:
		return
	if event is InputEventKey:
		if event.pressed and (event.keycode == KEY_ESCAPE or event.keycode == KEY_SPACE or event.keycode == KEY_ENTER):
			_wants_to_skip = true
			_maybe_proceed()
	elif event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_wants_to_skip = true
			_maybe_proceed()
