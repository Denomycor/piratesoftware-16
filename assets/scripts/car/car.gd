class_name Car extends RigidBody2D

const PARTICLE_RADIUS := 130
const FRONT_WHEEL_SIZE := 170
const BACK_WHEEL_SIZE := 240

var motor_strength: float = 500
var drift_friction_strength: float = 5
var torque_multiplier: float = 10
var perpendicular_multiplier: float = 0.25
var parallel_multiplier: float = 0.25

@export var weapon_vars: Array[CarVars]

@export var max_health: float = 100
@export var max_collision_damage: float = 25
@export var min_collision_speed: float = 300
@export var speed_for_max_collision_damage: float = 1500
@export var particle_scene: PackedScene

@export var back_wheels: Array[Sprite2D]
@export var front_wheels: Array[Sprite2D]

@onready var weapon_dock: WeaponDock = $weapon_dock
@onready var hurt_box: HurtBoxComponent = $HurtBoxComponent

var current_weapon: Weapon

var last_velocity: Vector2

var health: float

func _ready():
	health = max_health
	LevelContext.level.overlay.set_hp(health)
	contact_monitor = true
	max_contacts_reported = 1
	
	body_entered.connect(_on_collision)
	weapon_dock.weapon_switched.connect(_on_weapon_switched)
	hurt_box.has_taken_damage.connect(_on_take_damage)

	current_weapon = weapon_dock.get_current_weapon()
	current_weapon.fired.connect(apply_knockback)
	current_weapon.activated.connect(on_weapon_activated)
	current_weapon.deactivated.connect(on_weapon_deactivated)

func get_forward_direction() -> Vector2:
	return (to_global(Vector2.UP) - to_global(Vector2.ZERO))

func get_perpendicular_direction() -> Vector2:
	return (to_global(Vector2.UP) - to_global(Vector2.ZERO)).rotated(-PI / 2)

func _physics_process(_delta):
	apply_central_force(get_forward_direction() * motor_strength)
	apply_drift_friction()
	set_wheel_speed()
	last_velocity = linear_velocity

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

func get_last_velocity() -> Vector2:
	return last_velocity

func on_weapon_activated():
	pass

func on_weapon_deactivated():
	pass


#region Signals
func _on_weapon_switched():
	if current_weapon:
		current_weapon.fired.disconnect(apply_knockback)
		current_weapon.deactivated.disconnect(on_weapon_deactivated)
		current_weapon.activated.disconnect(on_weapon_activated)

	current_weapon = weapon_dock.get_current_weapon()
	current_weapon.fired.connect(apply_knockback)
	current_weapon.activated.connect(on_weapon_activated)
	current_weapon.deactivated.connect(on_weapon_deactivated)

	set_car_vars(weapon_vars[weapon_dock.current_idx])

func _on_take_damage(amount: float):
	health -= amount
	LevelContext.level.overlay.set_hp(health)
	if health <= 0:
		LevelContext.level.set_game_over()

func _on_collision(node: Node) -> void:
	var collision_direction := global_position.direction_to(node.global_position)
	var collision_speed := last_velocity.dot(collision_direction)
	var collision_damage := clampf(lerpf(0,max_collision_damage, (collision_speed-min_collision_speed)/(speed_for_max_collision_damage - min_collision_speed)),0,max_collision_damage)
	if node is RigidBody2D:
		var mass_ratio = node.mass/mass
		var velocity_ratio = 1
		if node.has_method("get_last_velocity"):
			velocity_ratio = clampf((last_velocity - node.get_last_velocity()).length()/speed_for_max_collision_damage, 0, 2)
		hurt_box.take_damage(collision_damage * mass_ratio * velocity_ratio)
		emit_break_particles(collision_damage * mass_ratio * velocity_ratio,collision_direction)
	elif node is StaticBody2D:
		hurt_box.take_damage(collision_damage)
		emit_break_particles(collision_damage,collision_direction)
	elif node is CharacterBody2D:
		#ainda n sei
		pass
	return

func emit_break_particles(damage: float, direction: Vector2) -> void:
	var particles: GPUParticles2D = particle_scene.instantiate()
	particles.amount_ratio = damage/max_collision_damage
	particles.emitting = true
	particles.position = direction * PARTICLE_RADIUS
	add_child(particles)
	particles.finished.connect(particles.queue_free)
#endregion

func set_car_vars(car_vars: CarVars) -> void:
	motor_strength = car_vars.motor_strength
	drift_friction_strength = car_vars.drift_friction_strength
	torque_multiplier = car_vars.torque_multiplier
	perpendicular_multiplier = car_vars.perpendicular_multiplier
	parallel_multiplier = car_vars.parallel_multiplier

func set_wheel_speed() -> void:
	var parallel_component = get_forward_direction().dot(linear_velocity)
	for wheel in back_wheels:
		wheel.material.set_shader_parameter("speed", Vector2(0,parallel_component/(float(BACK_WHEEL_SIZE)/2)))
	
	for wheel in front_wheels:
		wheel.material.set_shader_parameter("speed", Vector2(0,parallel_component/(float(FRONT_WHEEL_SIZE)/2)))