class_name Biker extends Enemy

const WHEEL_SIZE = 190

@export_range(500, 1500) var follow_range: int
@export var prediction_time: float = 0.3
@export var prediction_scalar := 3
@export var mass: float = 1.0  # Effective mass for collision damage ratio (CharacterBody2D has no mass)
@export var max_collision_damage: float = 25
@export var min_collision_speed: float = 300
@export var speed_for_max_collision_damage: float = 1500
@export var sprites: Array[Sprite2D]
@export var wheels: Array[Sprite2D]

@onready var gpu_particles: GPUParticles2D = $GPUParticles2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var last_velocity := Vector2.ZERO
var last_position := Vector2.ZERO
var actual_speed: float


func _ready() -> void:
	super()
	last_position = global_position
	notifier.screen_entered.connect(func():
		if randf() > 0.3:
			$scream.pitch_scale = randf_range(0.5, 1.5)
			$scream.play()
	)
	if follow_range == 0:
		follow_range = int(randf_range(500, 1500))

func attack() -> void:
	pass  # Biker's attacks are driven by update_movement(): BikerGun fires autonomously
	      # and collision damage is handled by _on_collision(). No discrete attack() call needed.


func update_movement() -> void:
	if dead:
		return
	if get_distance_to_target() > follow_range:
		set_chase_acceleration()
	else:
		set_mimic_acceleration()

func _physics_process(delta: float) -> void:
	if dead:
		return

	velocity += acceleration * delta
	look_at(global_position + velocity)

	move_and_slide()
	last_velocity = velocity
	actual_speed = (global_position - last_position).length() / delta
	last_position = global_position
	set_wheel_speed()

## Biker uses follow_range as the arrival radius, so we override the base.
func set_chase_acceleration() -> void:
	acceleration = SeekArriveSteeringBehaviour.get_steering_force(
		global_position, target.global_position, velocity, speed, max_acceleration, follow_range)

func set_mimic_acceleration() -> void:
	acceleration = SeekArriveSteeringBehaviour.get_steering_force(
		global_position, global_position + target.linear_velocity.normalized() * prediction_scalar,
		velocity, target.get_speed(), max_acceleration, follow_range)

func _on_die() -> void:
	$crash.play()
	($BikerGun as BikerGun).projectile_spawner_component.enabled = false
	($BikerGun as BikerGun).visible = false
	$Biker.visible = false
	$WheelB.visible = false
	$WheelF.visible = false
	collision.queue_free()
	for sprite: Sprite2D in sprites:
		sprite.visible = false
	gpu_particles.emitting = true
	create_tween().tween_callback(queue_free).set_delay(1)

func _on_collision(node: Node) -> void:
	var collision_direction := global_position.direction_to(node.global_position)
	var collision_speed := last_velocity.dot(collision_direction)
	var collision_damage := CollisionUtils.calculate_damage(
		collision_speed, min_collision_speed, speed_for_max_collision_damage, max_collision_damage)
	if node is RigidBody2D:
		var rigid := node as RigidBody2D
		var mass_ratio: float = rigid.mass / mass
		var velocity_ratio := 1.0
		if rigid.has_method("get_last_velocity"):
			velocity_ratio = clampf(
				(last_velocity - rigid.get_last_velocity()).length() / speed_for_max_collision_damage,
				0, 2)
		hurt_box.take_damage(collision_damage * mass_ratio * velocity_ratio)
		if collision_damage * mass_ratio * velocity_ratio > max_collision_damage / 10:
			$small_crash.play()
	elif node is StaticBody2D:
		hurt_box.take_damage(collision_damage)
		if collision_damage > max_collision_damage / 10:
			$small_crash.play()
	elif node is CharacterBody2D:
		pass

func set_wheel_speed() -> void:
	for wheel: Sprite2D in wheels:
		wheel.material.set_shader_parameter(
			"speed", Vector2(0, actual_speed / (float(WHEEL_SIZE) / 2)))
