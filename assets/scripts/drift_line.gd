class_name DriftLine extends Line2D

var max_points: int
var min_width: float
var max_width: float
var point_duration: float
var min_drift_strength: float
var max_drift_strength: float

var free_when_empty: bool = false

@onready var width_points: Array[float]
@onready var point_age: Array[float]

func _process(delta: float):
	for idx in point_age.size()-1:
		point_age[idx] += delta
		if point_age[idx] > point_duration:
			remove_drift_point(idx)
		idx += 1

	if get_point_count() > max_points:
		remove_drift_point(0)

	set_width_curve()

	if points.size() == 0 and free_when_empty:
		queue_free()

func set_params(max_drift_points: int, min_line_width: float, max_line_width: float, drift_point_duration: float, min_line_drift_strength: float, max_line_drift_strength: float) -> void:
	max_points = max_drift_points
	min_width = min_line_width
	max_width = max_line_width
	point_duration = drift_point_duration
	min_drift_strength = min_line_drift_strength
	max_drift_strength = max_line_drift_strength

func remove_drift_point(idx: int) -> void:
	width_points.remove_at.call_deferred(idx)
	point_age.remove_at.call_deferred(idx)
	remove_point.call_deferred(idx)

func add_drift_point(pos: Vector2, w: float) -> void:
	point_age.append(0.0)
	width_points.append(w)
	add_point(pos)

func set_width_curve() -> void:
	var temp_curve:= Curve.new()
	temp_curve.min_value = min_width
	temp_curve.max_value = max_width
	var idx := 1
	for point in width_points:
		temp_curve.add_point(Vector2(float(idx)/width_points.size(),point))
		idx += 1
	width_curve = temp_curve
