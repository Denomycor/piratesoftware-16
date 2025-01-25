class_name BoomArm extends Node2D

@export var mouse_slide_distance: float = 1000
@export var speed_slide_distance: float = 1000
@export var slide_ratio: float = 0.4
@export var max_slide_speed: float = 2000
@export var min_zoom: float = 1
@export var max_zoom: float = 2
@export var min_speed: float = 0
@export var max_speed: float = 300
@export var cam_speed: float = 3

@onready var camera: Camera2D = get_node("Camera2D")

func _process(delta):
	set_boom_position(delta)
	set_camera_zoom(delta)

func get_mouse_distance() -> float:
	return owner.get_local_mouse_position().distance_to(Vector2.ZERO)

func get_mouse_direction() -> Vector2:
	return owner.get_local_mouse_position().normalized()

func set_boom_position(delta: float) -> void:
	var mouse_cam_distance = clampf(get_mouse_distance(),0,mouse_slide_distance)
	var speed_cam_distance = clampf(lerpf(0,speed_slide_distance, owner.get_speed()/max_slide_speed),0,speed_slide_distance)
	var pos = (mouse_cam_distance * get_mouse_direction() + speed_cam_distance * owner.linear_velocity.normalized().rotated(-owner.rotation))* slide_ratio
	position = lerp(position, pos, delta * cam_speed)

func set_camera_zoom(delta: float) -> void:
	var speed = owner.linear_velocity.length()
	var zoom = clampf(lerpf(max_zoom, min_zoom, (speed - min_speed)/max_speed), min_zoom, max_zoom)
	camera.zoom = lerp(camera.zoom, Vector2(zoom,zoom), delta * cam_speed)
