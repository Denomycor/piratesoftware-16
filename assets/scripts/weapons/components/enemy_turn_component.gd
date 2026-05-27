class_name EnemyTurnComponent extends Node2D

## The node to rotate toward the car. Set in the inspector; falls back to parent
## for existing scenes that have not been wired yet.
@export var rotating_node: Node2D

var active := false
var locked := false

func _ready() -> void:
	if not rotating_node:
		rotating_node = get_parent() as Node2D

func _process(_delta: float) -> void:
	if not rotating_node:
		return
	if active && !locked:
		rotating_node.look_at(LevelContext.level.car.global_position)
	locked = false

func activate() -> void:
	active = true

func deactivate() -> void:
	active = false
	# Reset to original position
	if rotating_node:
		rotating_node.rotation = 0

func lock_turn(angle: float) -> void:
	locked = true
	if rotating_node:
		rotating_node.rotation = angle
