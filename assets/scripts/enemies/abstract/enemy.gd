class_name Enemy extends CharacterBody2D

@warning_ignore("UNUSED_SIGNAL")
signal died

@onready var hurt_box: HurtBoxComponent = $HurtBoxComponent
@export var speed: float = 200.0
@export var points: int = 20

var target: RigidBody2D

var movement_locked := false
## Set to true by each subclass's die() before queue_free.
## Declared here so BoostManager (and other systems) can read it on the Enemy base type.
var dead: bool = false


# --- Abstract interface ---
# Subclasses MUST implement: attack(), update_movement(), die(), _take_dmg()
# Subclasses MAY override: any other method
func attack():
	assert(false, "Enemy subclass must implement attack()")

func update_movement():
	assert(false, "Enemy subclass must implement update_movement()")

func die():
	assert(false, "Enemy subclass must implement die()")


func _physics_process(_delta: float) -> void:
	move_and_slide()

# Signal
func _take_dmg(_amount: float):
	assert(false, "Enemy subclass must implement _take_dmg()")

