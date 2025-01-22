class_name DriftLine extends Line2D

var max_points: int
var min_width: float
var max_width: float
var min_alpha: float
var max_alpha: float
var point_duration: float
var min_drift_strength: float
var max_drift_strength: float

var free_when_empty: bool = false

@onready var width_points: Array[float]
@onready var alpha_points: Array[float]
@onready var point_distance: Array[float]
@onready var point_age: Array[float]

func _physics_process(delta: float):
	for idx in point_age.size():
		point_age[idx] += delta
		if point_age[idx] > point_duration:
			remove_drift_point(idx)

	if get_point_count() > max_points:
		remove_drift_point(0)

	if points.size() <= 0 and free_when_empty:
		queue_free()
	set_width_curve.call_deferred()

func set_params(max_drift_points: int, min_line_width: float, max_line_width: float, min_drift_alpha: float, max_drift_alpha: float, drift_point_duration: float, min_line_drift_strength: float, max_line_drift_strength: float) -> void:
	max_points = max_drift_points
	min_width = min_line_width
	max_width = max_line_width
	min_alpha = min_drift_alpha
	max_alpha = max_drift_alpha
	point_duration = drift_point_duration
	min_drift_strength = min_line_drift_strength
	max_drift_strength = max_line_drift_strength

func remove_drift_point(idx: int) -> void:
	width_points.remove_at.call_deferred(idx)
	alpha_points.remove_at.call_deferred(idx)
	point_age.remove_at.call_deferred(idx)
	point_distance.remove_at.call_deferred(idx)
	remove_point.call_deferred(idx)
	set_width_curve.call_deferred()
	#set_drift_gradient.call_deferred()

func add_drift_point(pos: Vector2, w: float, a: float) -> void:
	var d: float
	point_age.append(0.0)
	width_points.append(w)
	alpha_points.append(a)

	if point_distance.size() == 0:
		d = 0
		point_distance.append(d)
	else:
		d = get_point_position(points.size()-1).distance_to(pos)
		point_distance.append(point_distance[point_distance.size()-1] + d)

	add_point(pos)
	set_width_curve.call_deferred()
	#set_drift_gradient.call_deferred()

func set_drift_gradient() -> void:
	var temp_gradient:= Gradient.new()
	for idx in alpha_points.size():
		var temp_color = default_color
		temp_color.a = alpha_points[idx]/255
		temp_gradient.add_point(1,temp_color)
	gradient = temp_gradient

func set_width_curve() -> void:
	var temp_curve:= Curve.new()
	temp_curve.min_value = min_width
	temp_curve.max_value = max_width
	for idx in width_points.size():
		temp_curve.add_point(Vector2(get_point_ratio(idx),width_points[idx]))
	width_curve = temp_curve

func get_point_ratio(idx: int) -> float:
	return (point_distance[idx]-point_distance[0])/(point_distance[point_distance.size()-1]-point_distance[0])