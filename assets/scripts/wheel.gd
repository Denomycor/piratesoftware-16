class_name Wheel extends Node2D

const DRIFT_LINE = preload("res://assets/scenes/car/drift_line.tscn")

@export var max_points: int = 1000
@export var min_width: float = 1
@export var max_width: float = 4
@export var point_duration: float = 3
@export var min_drift_strength: float = 10
@export var max_drift_strength: float = 40

var drift_strength: float
var drift_line: DriftLine
var arena: Node2D

func _ready():
	create_drift_line()

func _physics_process(_delta: float) -> void:
	drift_strength = owner.get_drift_strength()

func _process(_delta: float) -> void:
	if drift_strength >= min_drift_strength:
		if drift_line == null:
			create_drift_line()
		drift_line.add_drift_point(global_position, get_point_width())

	if drift_strength < min_drift_strength:
		if drift_line!=null:
			drift_line.free_when_empty = true
		drift_line = null

func create_drift_line() -> void:
	drift_line = DRIFT_LINE.instantiate()
	drift_line.set_params(max_points, min_width, max_width, point_duration, min_drift_strength, max_drift_strength)
	owner.get_parent().add_child.call_deferred(drift_line)

func get_point_width() -> float:
	return clampf(lerpf(min_width,max_width,(drift_strength-min_drift_strength)/max_drift_strength),min_width,max_width)
