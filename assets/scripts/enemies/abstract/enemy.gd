class_name Enemy extends CharacterBody2D

@warning_ignore("UNUSED_SIGNAL")
signal died

@onready var hurt_box: HurtBoxComponent = $HurtBoxComponent
@export var speed: float = 200.0
@export var points: int = 20

var target: RigidBody2D

var movement_locked := false


func attack():
	push_error("The attack function is not implemented for this enemy.")

func update_movement():
	push_error("The update_movement function is not implemented for this enemy.")

func die():
	push_error("The die function is not implemented for this enemy.")


func _physics_process(_delta: float) -> void:
	move_and_slide()

# Signal
func _take_dmg(_amount: float):
	push_error("The _take_dmg function is not implemented for this enemy.")

