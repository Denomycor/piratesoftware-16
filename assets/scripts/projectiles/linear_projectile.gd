class_name LinearProjectile extends CharacterBody2D


@export var speed: float
@export var lifetime: float

var timer: Tween


func _ready() -> void:
	timer = create_tween()
	timer.tween_callback(destroy).set_delay(lifetime)


func set_properties(pos: Vector2, rot: float) -> void:
	global_position = pos
	rotation = rot


func _physics_process(_delta) -> void:
	var motion := Vector2.from_angle(rotation) * speed
	move_and_collide(motion)


func destroy() -> void:
	queue_free()
