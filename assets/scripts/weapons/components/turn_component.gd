class_name TurnComponent extends Node2D


@onready var parent: Node2D = get_parent()


func _process(_delta: float) -> void:
	parent.look_at(get_global_mouse_position())

