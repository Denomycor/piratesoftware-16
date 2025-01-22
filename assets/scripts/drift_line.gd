class_name DriftLine extends Line2D

@export var max_points: int = 1000
@export var min_width: float = 1
@export var max_width: float = 4
@export var line_duration: float = 3
@export var min_drift_strength: float = 10
@export var max_drift_strength: float = 40

@onready var curve := Curve2D.new()
@onready var width_points: Array[float]

func _physics_process(_delta):
	draw_drift_line()

func draw_drift_line() -> void:
	add_point(global_position)
	width_points.append(get_point_width())
	if curve.get_baked_points().size() > max_points:
		remove_point(0)
		width_points.pop_back()
	points = curve.get_baked_points()
	set_width_curve()

func fade_drift_line() -> void:
	set_physics_process(false)
	var tween := get_tree().create_tween()
	tween.tween_property(self,"modulate:a", 0, line_duration)
	await  tween.finished
	queue_free()

func get_point_width() -> float:
	var drift_strength :float = owner.get_drift_strength()
	return clampf(lerpf(min_width,max_width,(drift_strength-min_drift_strength)/max_drift_strength),min_width,max_width)

func set_width_curve() -> void:
	var temp_curve:= Curve.new()
	temp_curve.min_value = min_width
	temp_curve.max_value = max_width
	var idx := 1
	for point in width_points:
		temp_curve.add_point(Vector2(float(idx)/width_points.size(),point))
		idx += 1
	width_curve = temp_curve
