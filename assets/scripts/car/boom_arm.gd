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
## Maximum rotation angle when shaking
@export var shake_rot_angle: float 
## Maximum nr of pixels transversed in x and y during shake
@export var shake_offset : Vector2
## Percentage of shaking reduction per secon 
@export_range(0,1) var shake_decay 

@onready var camera: Camera2D = get_node("Camera2D")
@onready var noise : FastNoiseLite = FastNoiseLite.new() # noise for shake variation

var trauma : float = 0 # Shake strength
var noise_y : int = 0 # Used to transverse linearly through the noise

func _ready() -> void:
	noise.seed = randi()

func _process(delta):
	set_boom_position(delta)
	set_camera_zoom(delta)
	if trauma:
		trauma = max(trauma - shake_decay*delta, 0)
		_shake_camera()

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

# Call this method to add shake to the camera. Trauma (i.e. shake strength) is a percentage, 
# and amount should be between 0 and 1.
func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1)

func _shake_camera() -> void:
	var shake_amount = pow(trauma, 2)
	noise_y += 1
	camera.rotation = shake_rot_angle * shake_amount * noise.get_noise_2d(1, noise_y)
	camera.offset.x = shake_offset.x * shake_amount * noise.get_noise_2d(50, noise_y)
	camera.offset.y = shake_offset.y * shake_amount * noise.get_noise_2d(100, noise_y)
