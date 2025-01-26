class_name Biker extends Enemy

@export var health: float = 20
@export_range(500, 1500) var follow_range: int
@export var prediction_time: float = 0.3
@export var max_angle_diff: float = 1.0

@onready var line_of_sight: RayCast2D = $LineOfSight
@onready var projectile_spawner_component = $ProjectileSpawnerComponent


func _ready() -> void:
	projectile_spawner_component.shoot_projectile.connect(func(from: Vector2, rot: float, _data):
		var projectile: LinearProjectile = PROJECTILE_SCENE.instantiate()
		projectile.set_properties(from, rot)

		LevelContext.level.get_node("World").add_child(projectile)
	)
	hurt_box.has_taken_damage.connect(_take_dmg)
	if follow_range == 0:
		follow_range = int(randf_range(500, 1500))

func _process(delta: float) -> void:
	attack()
	

func attack():
	if line_of_sight.is_colliding():
		projectile_spawner_component.shoot(line_of_sight.target_position)

func update_movement():
	pass
	
	
func _physics_process(delta: float) -> void:

	var target_dist = target.global_position.distance_to(global_position)
	
	var time_to_collision = target.linear_velocity.distance_to(global_position) / target.linear_velocity.length()
	var predicted_target_position = target.global_position + (target.linear_velocity * time_to_collision * delta)
	
	if velocity == Vector2.ZERO:
		velocity = global_position.direction_to(predicted_target_position) * speed * delta
	
	var desired_velocity: Vector2
	var desired_speed: float
	
	if target_dist > follow_range:
		desired_velocity = global_position.direction_to(predicted_target_position)
		desired_speed = speed
	else:
		desired_velocity = target.linear_velocity.normalized()
		desired_speed = minf(speed, target.linear_velocity.length())
	
	var current_angle = velocity.angle()
	var target_angle = desired_velocity.angle()
	var angle_diff = target_angle - current_angle
	angle_diff = clampf(angle_diff, -max_angle_diff * delta, max_angle_diff * delta)

	print("max angle diff: ", max_angle_diff * delta)
	print("current angle: ", current_angle)
	print("target angle: ", target_angle)
	print("angle diff: ", angle_diff)
	print("desired velocity: ", desired_velocity)
	print("current velocity: ", velocity)


	velocity = velocity.rotated(angle_diff).normalized() * desired_speed
	look_at(global_position + velocity)
	
	move_and_slide()


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
