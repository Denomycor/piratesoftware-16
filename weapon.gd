extends Node2D

func _physics_process(_delta):
	rotate_to_mouse()

func rotate_to_mouse() -> void:
	look_at(get_global_mouse_position())