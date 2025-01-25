class_name LinearProjectile extends CharacterBody2D


@export var speed: float
@export var lifetime: float

var timer: Tween
var travel_direction: Vector2
var inherited_velocity := Vector2.ZERO


func _ready() -> void:
	timer = create_tween()
	timer.tween_callback(destroy).set_delay(lifetime)


func set_properties(pos: Vector2, rot: float) -> void:
	global_position = pos
	rotation = rot
	travel_direction = Vector2.from_angle(rotation)


func _physics_process(_delta) -> void:
	var motion := (travel_direction * speed) + inherited_velocity
	move_and_collide(motion)


func destroy() -> void:
	queue_free()

