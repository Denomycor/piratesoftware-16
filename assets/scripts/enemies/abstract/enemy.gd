class_name Enemy extends CharacterBody2D

@warning_ignore("UNUSED_SIGNAL")
signal died

@export var speed: float = 200.0
@export var points: int = 20
## Override in subclass scenes to set per-enemy health.
@export var health: float = 100.0
## Override in subclass scenes to tune steering force.
@export var max_acceleration: float = 100000.0

@onready var hurt_box: HurtBoxComponent = $HurtBoxComponent

var target: RigidBody2D
var acceleration: Vector2 = Vector2.ZERO

var movement_locked := false
## Set to true by die() before _on_die() is called.
## Declared here so BoostManager (and other systems) can read it on the Enemy base type.
var dead: bool = false


func _ready() -> void:
	hurt_box.has_taken_damage.connect(_take_dmg)


# --- Abstract interface ---
# Subclasses MUST implement: attack(), update_movement()
# Subclasses MAY override: _on_die() for subclass-specific death cleanup
func attack() -> void:
	assert(false, "Enemy subclass must implement attack()")

func update_movement() -> void:
	assert(false, "Enemy subclass must implement update_movement()")

func die() -> void:
	dead = true
	velocity = Vector2.ZERO
	hurt_box.has_taken_damage.disconnect(_take_dmg)
	hurt_box.queue_free()
	_on_die()
	died.emit()

## Override in subclasses to add subclass-specific death cleanup
## (free collision shape, hide sprite, trigger particles, etc.)
func _on_die() -> void:
	pass

## Default damage handler: reduces health and calls die() at zero.
## Override only when the subclass needs non-standard damage logic.
func _take_dmg(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		die()

## Returns world-space distance from this enemy to its target.
func get_distance_to_target() -> float:
	return global_position.distance_to(target.global_position)

## Steers toward the target using SeekArrive with arrival_radius = 0.
## Override in subclasses that need a different arrival radius (e.g. Biker).
func set_chase_acceleration() -> void:
	acceleration = SeekArriveSteeringBehaviour.get_steering_force(
		global_position, target.global_position, velocity, speed, max_acceleration, 0)
