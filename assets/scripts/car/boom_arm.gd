class_name BoomArm extends Node2D

@export var mouse_slide_distance: float = 1000
@export var slide_ratio: float = 0.4
@export var min_zoom: float = 1
@export var max_zoom: float = 2
@export var min_speed: float = 0
@export var max_speed: float = 300

@onready var camera: Camera2D = get_node("Camera2D")

func _process(delta):
	set_boom_position()
	set_camera_zoom(delta)

func get_mouse_distance() -> float:
	return (get_local_mouse_position() - Vector2.ZERO).distance_to(Vector2.ZERO)

func get_mouse_direction() -> Vector2:
	return (get_local_mouse_position() - Vector2.ZERO).normalized()

func set_boom_position() -> void:
	position = clampf(get_mouse_distance(),0,mouse_slide_distance) * slide_ratio * get_mouse_direction()

func set_camera_zoom(delta: float) -> void:
	var speed = owner.linear_velocity.length()
	var zoom = clampf(lerpf(max_zoom, min_zoom, (speed - min_speed)/max_speed), min_zoom, max_zoom)
	camera.zoom = lerp(camera.zoom, Vector2(zoom,zoom), delta)
