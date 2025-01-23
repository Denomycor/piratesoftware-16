class_name Biker extends Enemy

@export var health: int = 20
@export var weapon_range: int = 2000
@export var prediction_time: float = 0.3

@onready var line_of_sight: RayCast2D = $LineOfSight


var predicted_target_position: Vector2

func _ready() -> void:
	hurt_box.has_taken_damage.connect(_take_dmg)

func attack():
	if line_of_sight.is_colliding():
		print("I am the biker")

func update_movement():

	var distance = global_position.distance_to(target.global_position)

	if distance <= weapon_range:
		velocity = global_position.direction_to(target.global_position) * speed
	else:
		#var time_to_collision = distance / speed
		predicted_target_position = target.global_position + target.linear_velocity * prediction_time
		var direction = global_position.direction_to(predicted_target_position)
		velocity = direction * speed

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	var distance = global_position.distance_to(target.global_position)

	if distance <= weapon_range:
		look_at(target.global_position)
	else:
		look_at(predicted_target_position)

func die():
	queue_free()

# Signal
func _take_dmg(amount: int):
	health -= amount
	if health <= 0:
		die()
