class_name Enemy extends CharacterBody2D


@onready var hurt_box: HurtBoxComponent = $Hp
@export var speed: float = 200.0

var target: RigidBody2D

func attack():
	push_error("The attack function is not implemented for this enemy.")

func update_movement():
	push_error("The update_movement function is not implemented for this enemy.")

func die():
	push_error("The die function is not implemented for this enemy.")


func _physics_process(_delta: float) -> void:
	move_and_slide()

# Signal
func _take_dmg(_amount: int):
	push_error("The _take_dmg function is not implemented for this enemy.")
