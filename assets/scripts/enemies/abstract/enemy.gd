class_name Enemy extends CharacterBody2D

@warning_ignore("UNUSED_SIGNAL")
signal died

@export var speed: float = 200.0
@export var points: int = 20

@onready var hurt_box: HurtBoxComponent = $HurtBoxComponent

var target: RigidBody2D

var movement_locked := false
## Set to true by die() before _on_die() is called.
## Declared here so BoostManager (and other systems) can read it on the Enemy base type.
var dead: bool = false


# --- Abstract interface ---
# Subclasses MUST implement: attack(), update_movement(), _take_dmg()
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

# Signal
func _take_dmg(_amount: float) -> void:
	assert(false, "Enemy subclass must implement _take_dmg()")
