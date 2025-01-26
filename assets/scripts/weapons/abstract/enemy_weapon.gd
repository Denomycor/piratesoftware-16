class_name EnemyWeapon extends Node2D

@export var activation_range: float
@onready var parent: CharacterBody2D = get_parent()

func get_enemy_direction() -> Vector2:
	return parent.velocity