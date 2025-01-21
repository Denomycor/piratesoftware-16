class_name Car extends CharacterBody2D

@export var speed: float = 20
var target_velocity: Vector2
var angular_speed: float

func _physics_process(_delta):
	target_velocity = speed * get_forward_direction()
	move_and_slide()

func get_forward_direction() -> Vector2:
	return (to_global(Vector2.UP) - to_global(Vector2.ZERO))

func apply_impulse(impulse: Vector2) -> void:
	var parallel_component := get_forward_direction().dot(impulse)
	var perpendicular_component := get_forward_direction().rotated(PI/2).dot(impulse)

	velocity += parallel_component * get_forward_direction()
	angular_speed -= perpendicular_component