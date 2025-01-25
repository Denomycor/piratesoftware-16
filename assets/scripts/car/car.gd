class_name Car extends RigidBody2D

@export var motor_strength: float
@export var drift_friction_strength: float
@export var torque_multiplier: float
@export var perpendicular_multiplier: float
@export var parallel_multiplier: float
@export var health: int = 100
@export var max_collision_damage: int = 25
@export var min_collision_speed: float = 300
@export var speed_for_max_collision_damage: float = 4000


@onready var weapon_dock: WeaponDock = $weapon_dock
@onready var hurt_box: HurtBoxComponent = $HurtBoxComponent

var current_weapon: Weapon

func _ready():
	contact_monitor = true
	max_contacts_reported = 10
	
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

func _on_take_damage(amount: int):
	health -= amount
	if health <= 0:
		LevelContext.level.set_game_over()

func _on_collision(node: Node) -> void:
	var collision_damage := clampi(int(lerpf(0,max_collision_damage, (get_speed()-min_collision_speed)/(speed_for_max_collision_damage - min_collision_speed))),0,max_collision_damage)
	if node is RigidBody2D:
		var mass_ratio = node.mass/mass
		hurt_box.take_damage(collision_damage * mass_ratio)
	elif node is StaticBody2D:
		hurt_box.take_damage(collision_damage)
	elif node is CharacterBody2D:
		#ainda n sei
		pass
	return


#endregion