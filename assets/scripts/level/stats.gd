class_name Stats extends Node

@export var min_drift_strength := 100

var is_game_over: bool = false

var points: float
var time_survived: float
var kills: int = 0
var max_speed: float
var max_drift_duration: float
var speed: float
var _is_drifting := false
var current_drift_time: float = 0

@export var points_per_second: int
@export var overlay: Overlay
@export var speed_conversion_ratio: float = 1.0 / 60.0

func add_points(amount: float) -> void:
	points += amount
	overlay.set_points(int(points))

func increment_kills() -> void:
	kills += 1
	overlay.set_kills(kills)

func check_max_speed() -> void:
	if speed > max_speed:
		max_speed = speed

func _physics_process(delta: float):
	if not is_game_over:
		speed = LevelContext.level.car.get_speed() * speed_conversion_ratio
		check_max_speed()
		check_drift(delta)
		add_points(points_per_second * delta)
		time_survived += delta
		overlay.set_hp(LevelContext.level.car.health)
		overlay.set_speed(speed)

func check_drift(delta: float):
	var drift_strength := LevelContext.level.car.get_drift_strength(1)
	if drift_strength < min_drift_strength:
		_is_drifting = false
		current_drift_time = 0
	else:
		_is_drifting = true
		current_drift_time += delta
	if current_drift_time > max_drift_duration:
		max_drift_duration = current_drift_time

