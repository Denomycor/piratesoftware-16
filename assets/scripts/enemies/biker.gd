class_name Biker extends Enemy

@export var health: int = 20
@export_range(500, 1500) var follow_range: int
@export var prediction_time: float = 0.3
@export var max_angle_diff: float = 0.05

@onready var line_of_sight: RayCast2D = $LineOfSight


func _ready() -> void:
	hurt_box.has_taken_damage.connect(_take_dmg)
	if follow_range == 0:
		follow_range = int(randf_range(300, 1300))

func attack():
	if line_of_sight.is_colliding():
		print("I am the biker")

func update_movement():
	pass
	
	
func _physics_process(delta: float) -> void:

	var radius = follow_range
	var target_dist: float = target.global_position.distance_to(global_position)
	
	# Calculate angle between biker's velocity and target's velocity
	var angle_between = abs(velocity.angle_to(target.linear_velocity))
	var is_inside_angle = angle_between < PI / 4 # Consider "inside" if within 45 degrees
	
	# Calculate predicted position
	var time_to_collision = target.linear_velocity.length() / target.linear_velocity.distance_to(global_position)
	var predicted_target_position = target.global_position + (target.linear_velocity * time_to_collision * delta)
	
	if velocity == Vector2.ZERO:
		velocity = global_position.direction_to(predicted_target_position) * speed * delta
	
	# Adjust velocity based on position and angle
	var desired_velocity: Vector2
	var desired_speed: float
	
	if target_dist > radius || !is_inside_angle:
		# Try to get inside radius and angle
		desired_velocity = global_position.direction_to(predicted_target_position)
		desired_speed = speed
	else:
		# Match target's trajectory when in good position
		desired_velocity = target.linear_velocity.normalized()
		desired_speed = minf(speed, target.linear_velocity.length())
	
	# Smooth rotation
	var current_angle = velocity.angle()
	var target_angle = desired_velocity.angle()
	var angle_diff = target_angle - current_angle
	angle_diff = clampf(angle_diff, -max_angle_diff * delta, max_angle_diff * delta)
	
	velocity = velocity.rotated(angle_diff).normalized() * desired_speed
	look_at(global_position + velocity)

	if velocity.length() == 0:
		print("velocity is zero for biker at position: ", global_position)
		print("current target distance: ", target.global_position.distance_to(global_position))
		print("current velocity: ", velocity)
	
	move_and_slide()


func die():
	queue_free()

# Signal
func _take_dmg(amount: int):
	health -= amount
	if health <= 0:
		die()
