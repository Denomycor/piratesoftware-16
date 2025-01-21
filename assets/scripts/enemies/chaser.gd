extends Enemy

@export var health: int = 100

func _ready() -> void:
	connect("has_taken_damage", _take_dmg)


func attack():
	print("I am the pacifist")

func update_movement():
	print("global position: ", global_position)
	print("target global position: ", target.global_position)
	print("hand direction normalized position: ", (target.global_position - global_position).normalized())
	print("target global position normalized: ", target.global_position.normalized())

	var direction = global_position.direction_to(target.global_position)
	print("Direction to target: ", direction)
	velocity = direction * speed
	print("Velocity set to: ", velocity)


func die():
	print("I am gonna die")
	
# Signal
func _take_dmg(amount: int):
	health -= amount
