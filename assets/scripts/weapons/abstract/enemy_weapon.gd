class_name EnemyWeapon extends Node2D

@export var activation_range: float
## The enemy body that owns this weapon. Set in the inspector; falls back to
## parent for existing scenes that have not been wired yet.
@export var owner_enemy: CharacterBody2D

func _ready() -> void:
	if not owner_enemy:
		owner_enemy = get_parent() as CharacterBody2D
