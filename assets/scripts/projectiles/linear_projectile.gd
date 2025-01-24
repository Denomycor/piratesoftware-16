class_name LinearProjectile extends CharacterBody2D


@export var speed: float
@export var reach: float

var reach_acc := 0.0


func set_properties(pos: Vector2, rot: float) -> void:
	global_position = pos
	rotation = rot


func _physics_process(_delta) -> void:
	var motion := Vector2.from_angle(rotation) * speed
	if (reach_acc < reach):
		reach_acc += motion.length()
		move_and_collide(motion)
	else:
		destroy()


func destroy() -> void:
	queue_free()
