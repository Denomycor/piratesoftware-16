class_name SkeletonTest extends Enemy

@export var health: int = 10

@onready var skeleton: Skeleton2D = $Skeleton2D

@onready var arm_left: Bone2D = $Skeleton2D/Hip/Chest/ArmL
@onready var arm_right: Bone2D = $Skeleton2D/Hip/Chest/ArmR

func _ready() -> void:
	hurt_box.has_taken_damage.connect(_take_dmg)

func attack():
	print("I am the pacifist")

func update_movement():
	var direction = global_position.direction_to(target.global_position)
	look_at(target.global_position)
	velocity = direction * speed


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	print("will rotate")

	arm_left.rotation = PI * delta
	arm_right.rotation = PI * delta

	print("did rotate")

	
func die():
	queue_free()

# Signal
func _take_dmg(amount: int):
	health -= amount
	if health <= 0:
		die()
