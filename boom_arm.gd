class_name BoomArm extends Node2D

@export var mouse_slide_distance: float = 1000
@export var slide_ratio: float = 0.4

func _process(_delta):
	position = clampf(get_mouse_distance(),0,mouse_slide_distance) * slide_ratio * get_mouse_direction()

func get_mouse_distance() -> float:
	return (get_local_mouse_position() - Vector2.ZERO).distance_to(Vector2.ZERO)

func get_mouse_direction() -> Vector2:
	return (get_local_mouse_position() - Vector2.ZERO).normalized()
