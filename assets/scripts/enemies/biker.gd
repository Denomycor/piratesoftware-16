class_name Biker extends Enemy

@export var health: float = 20
@export_range(500, 1500) var follow_range: int
@export var prediction_time: float = 0.3
@export var max_accelaration := 100000
@export var prediction_scalar := 1000


func _ready() -> void:
	hurt_box.has_taken_damage.connect(_take_dmg)
	if follow_range == 0:
		follow_range = int(randf_range(500, 1500))

func attack():
	pass

func update_movement():
	pass
	
func _physics_process(delta: float) -> void:
	if get_distance_to_target() > follow_range:
		velocity = get_chase_velocity(delta)
	else:
		velocity = get_mimic_velocity(delta)

	look_at(global_position + velocity)
	
	move_and_slide()

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
