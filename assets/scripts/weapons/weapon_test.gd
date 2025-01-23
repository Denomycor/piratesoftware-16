class_name WeaponTest extends Node2D

@export var strength: float
signal fired(impulse: Vector2)

func _physics_process(_delta):
	rotate_to_mouse()

func rotate_to_mouse() -> void:
	look_at(get_global_mouse_position())

func get_mouse_direction() -> Vector2:
	return (get_global_mouse_position() - global_position).normalized()

func _input(event):
	if event is InputEventMouseButton:
		fired.emit(-get_mouse_direction() * strength)
