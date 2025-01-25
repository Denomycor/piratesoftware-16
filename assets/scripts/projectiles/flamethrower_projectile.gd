class_name FlamethrowerProjectile extends Node2D


@export var speed: float
@export var lifetime: float

@onready var collision_shape: CollisionShape2D = $HitBoxComponent/CollisionShape2D

var timer: Tween
var travel_direction: Vector2
var inherited_velocity := Vector2.ZERO


func _ready() -> void:
	timer = create_tween()
	timer.tween_callback(destroy).set_delay(lifetime)


func set_properties(pos: Vector2, rot: float) -> void:
	global_position = pos
	travel_direction = Vector2.from_angle(rot)


func _physics_process(delta) -> void:
	collision_shape.scale += Vector2.ONE * 0.1 
	var motion := (travel_direction * speed) + inherited_velocity
	global_position += motion * delta


func destroy() -> void:
	queue_free()

