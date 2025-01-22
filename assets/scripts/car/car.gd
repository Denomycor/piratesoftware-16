class_name Car extends RigidBody2D

@export var motor_strength: float = 100
@export var drift_friction_strength: float = 5
@export var torque_multiplier: float = 2
@export var perpendicular_multiplier: float = .25
@export var parallel_multiplier: float = .25
@export var weapon: Weapon

func _ready():
	weapon.fired.connect(apply_knockback)

func get_forward_direction() -> Vector2:
	return (to_global(Vector2.UP) - to_global(Vector2.ZERO))

func get_perpendicular_direction() -> Vector2:
	return (to_global(Vector2.UP) - to_global(Vector2.ZERO)).rotated(-PI / 2)

func _physics_process(_delta):
	apply_central_force(get_forward_direction() * motor_strength)
	apply_drift_friction()

func apply_drift_friction():
	var perpendicular_component := get_perpendicular_direction().dot(linear_velocity)
	apply_central_force(-get_perpendicular_direction() * perpendicular_component * drift_friction_strength)

func apply_knockback(impulse: Vector2) -> void:
	var perpendicular_component := get_perpendicular_direction().dot(impulse)
	var parallel_component := get_forward_direction().dot(impulse)
	apply_central_impulse(parallel_component * get_forward_direction() * parallel_multiplier)
	apply_central_impulse(perpendicular_component * get_perpendicular_direction() * perpendicular_multiplier)
	apply_torque_impulse(perpendicular_component * torque_multiplier)

func get_drift_strength() -> float:
	return abs(get_perpendicular_direction().dot(linear_velocity) * drift_friction_strength)