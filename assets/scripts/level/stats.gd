class_name Stats extends Node

## Survival time (seconds) required to trigger victory. 15 minutes.
const VICTORY_TIME: float = 900.0

signal points_changed(points: int)
signal kills_changed(kills: int)
signal speed_changed(speed: float)
## Emitted once when the player survives VICTORY_TIME seconds. Wired by Level to set_victory().
signal victory_reached

## Direct reference to the Car — set via inspector (wired in test_level.tscn).
@export var car: Car

@export var min_drift_strength := 100

var is_game_over: bool = false
var _victory_triggered: bool = false

var points: float
var time_survived: float
var kills: int = 0
var max_speed: float
var max_drift_duration: float
var speed: float
var _is_drifting := false
var current_drift_time: float = 0

@export var points_per_second: int
@export var speed_conversion_ratio: float = 1.0 / 20.0

func add_points(amount: float) -> void:
	points += amount * BoostManager.points_multiplier
	points_changed.emit(int(points))

func increment_kills() -> void:
	kills += 1
	kills_changed.emit(kills)

func check_max_speed() -> void:
	if speed > max_speed:
		max_speed = speed

func _physics_process(delta: float) -> void:
	if not is_game_over:
		speed = roundf(car.get_speed() * speed_conversion_ratio)
		check_max_speed()
		check_drift(delta)
		add_points(points_per_second * delta)
		time_survived += delta
		speed_changed.emit(speed)
		# Victory condition: survive 15 minutes
		if not _victory_triggered and time_survived >= VICTORY_TIME:
			_victory_triggered = true
			is_game_over = true
			victory_reached.emit()

func check_drift(delta: float) -> void:
	var drift_strength := car.get_drift_strength(1)
	if drift_strength < min_drift_strength:
		_is_drifting = false
		current_drift_time = 0
	else:
		_is_drifting = true
		current_drift_time += delta
	if current_drift_time > max_drift_duration:
		max_drift_duration = current_drift_time
