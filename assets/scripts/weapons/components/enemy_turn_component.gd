class_name EnemyTurnComponent extends Node2D

@onready var parent: Node2D = get_parent()

var active:= false
var locked:= false

func _process(_delta: float) -> void:
	if active && !locked:
		parent.look_at(LevelContext.level.car.global_position)
	locked = false

func activate() -> void:
	active = true

func deactivate() -> void:
	active = false
	#Reset to original position
	parent.rotation = 0

func lock_turn(angle: float) -> void:
	locked = true
	parent.rotation = angle
