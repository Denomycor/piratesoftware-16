class_name EnemyTurnComponent extends Node2D

@onready var parent: Node2D = get_parent()

var active:= false

func _process(_delta: float) -> void:
	if active:
		parent.look_at(LevelContext.level.car.global_position)

func activate() -> void:
	active = true

func deactivate(direction: Vector2) -> void:
	active = false
	#Reset to original position
	parent.look_at(direction.normalized())
