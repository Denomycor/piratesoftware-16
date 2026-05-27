class_name TurnComponent extends Node2D

## The node to rotate toward the mouse. Set in the inspector; falls back to parent
## for existing scenes that have not been wired yet.
@export var rotating_node: Node2D

func _ready() -> void:
	if not rotating_node:
		rotating_node = get_parent() as Node2D

func _process(_delta: float) -> void:
	if rotating_node:
		rotating_node.look_at(get_global_mouse_position())
