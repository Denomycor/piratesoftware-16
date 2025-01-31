class_name GooProjectile extends Node2D


@export var speed_from: float
@export var speed_to: float
@export var drag: float
@export var lifetime: float

@export var scale_curve: Curve

var timer: Tween
var travel_direction: Vector2

var speed: float

func _ready() -> void:
	timer = create_tween()
	timer.tween_callback(destroy).set_delay(lifetime)
	speed = randf_range(speed_from, speed_to)

	create_tween().tween_method(func(value: float):
		scale = Vector2.ONE * scale_curve.sample(value)
	, 0.0, 1.0, lifetime)
	# $GPUParticles2D.emitting = true
	# $GPUParticles2D.finished.connect(queue_free)


func set_properties(pos: Vector2, rot: float) -> void:
	global_position = pos
	travel_direction = Vector2.from_angle(rot)


func _physics_process(delta) -> void:
	# collision_shape.scale += Vector2.ONE * 0.1 
	var motion := (travel_direction * maxf(speed, 0))
	global_position += motion * delta
	speed -= drag * delta


func destroy() -> void:
	# collision_shape.set_deferred("disbled", true)
	queue_free()

