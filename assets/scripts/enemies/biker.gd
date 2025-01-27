class_name Biker extends Enemy

const PARTICLE_RADIUS = 120

@export var health: float = 20
@export_range(500, 1500) var follow_range: int
@export var prediction_time: float = 0.3
@export var max_accelaration := 100000
@export var prediction_scalar := 1000
@export var max_collision_damage: float = 25
@export var min_collision_speed: float = 300
@export var speed_for_max_collision_damage: float = 1500

@export var particle_scene: PackedScene

var last_velocity := Vector2.ZERO


func _ready() -> void:
	hurt_box.has_taken_damage.connect(_take_dmg)
	if follow_range == 0:
		follow_range = int(randf_range(500, 1500))

func update_movement():
	pass
	
func _physics_process(delta: float) -> void:
	if get_distance_to_target() > follow_range:
		velocity = get_chase_velocity(delta)
	else:
		velocity = get_mimic_velocity(delta)
	look_at(global_position + velocity)
	
	move_and_slide()
	last_velocity = velocity

func get_distance_to_target() -> float:
	return target.global_position.distance_to(global_position)

func get_chase_velocity(delta: float) -> Vector2:
	var acceleration := SeekArriveSteeringBehaviour.get_steering_force(global_position, target.global_position, velocity, speed, max_accelaration, follow_range)
	return velocity + acceleration * delta

func get_mimic_velocity(delta: float) -> Vector2:
	var acceleration := SeekArriveSteeringBehaviour.get_steering_force(global_position, global_position + target.linear_velocity * delta * prediction_scalar, velocity, target.get_speed(), max_accelaration, follow_range)
	return velocity + acceleration * delta

func die():
	LevelContext.level.stats.increment_kills()
	LevelContext.level.stats.add_points(points)
	queue_free()
	died.emit()

# Signal
func _take_dmg(amount: float):
	health -= amount
	if health <= 0:
		die()

func _on_collision(node: Node) -> void:
	var collision_direction := global_position.direction_to(node.global_position)
	var collision_speed := last_velocity.dot(collision_direction)
	var collision_damage := clampf(lerpf(0,max_collision_damage, (collision_speed-min_collision_speed)/(speed_for_max_collision_damage - min_collision_speed)),0,max_collision_damage)
	if node is RigidBody2D:
		var mass_ratio = node.mass
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