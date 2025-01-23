class_name Stats extends Node
var is_game_over: bool = false

var points: float
var time_survived: float
var kills: int
var max_speed: float
var max_drift_duration: float

@export var points_per_second: int
@export var overlay: Overlay

func add_points(amount: float) -> void:
	points += amount
	overlay.set_points(int(points))

func increment_kills() -> void:
	kills += 1

func check_max_speed() -> void:
	var speed = LevelContext.get_speed
	if speed > max_speed:
		max_speed = speed

func _physics_process(delta: float):
	if not is_game_over:
		add_points(points_per_second * delta)
		time_survived += delta
