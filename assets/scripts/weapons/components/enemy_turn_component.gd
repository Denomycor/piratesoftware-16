class_name EnemyTurnComponent extends Node2D

@onready var parent: Node2D = get_parent()

var active:= false

func _process(_delta: float) -> void:
	if active:
		parent.look_at(LevelContext.level.car.global_position)

func activate() -> void:
	active = true

func deactivate() -> void:
	active = false
	#Reset to original position
	parent.rotation = 0
