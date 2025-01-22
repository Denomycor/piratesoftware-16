class_name Biker extends Enemy

@export var health: int = 20
@export var prediction_time: float = .7

@onready var line_of_sight: RayCast2D = $LineOfSight

func _ready() -> void:
	hurt_box.has_taken_damage.connect(_take_dmg)

func attack():
    if line_of_sight.is_colliding():
	    print("I am the biker")

func update_movement():
	var predicted_target_position = target.global_position + target.velocity * prediction_time
	var direction = global_position.direction_to(predicted_target_position)
	look_at(predicted_target_position)
	velocity = direction * speed

func die():
	queue_free()

# Signal
func _take_dmg(amount: int):
	health -= amount
	if health <= 0:
		die()
