class_name Car extends RigidBody2D

@export var motor_strength: float
@export var drift_friction_strength: float
@export var torque_multiplier: float
@export var perpendicular_multiplier: float
@export var parallel_multiplier: float
@export var weapon: WeaponTest
@export var health: int = 20

@onready var hurt_box: HurtBoxComponent = $HurtBoxComponent

func _ready():
	weapon.fired.connect(apply_knockback)
	hurt_box.has_taken_damage.connect(on_take_damage)

func on_take_damage(amount: int):
	health -= amount
	if health <= 0:
		LevelContext.level.set_game_over()

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

func get_drift_strength(strength_torque_multiplier: float) -> float:
		return abs(get_perpendicular_direction().dot(linear_velocity) * drift_friction_strength * abs(angular_velocity) * strength_torque_multiplier)

func get_speed() -> float:
	return linear_velocity.length()
