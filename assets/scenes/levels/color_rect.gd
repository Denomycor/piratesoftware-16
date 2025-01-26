extends ColorRect

var boom_arm: BoomArm
var debug_camera: Camera2D
var debug = false

func _ready():
	boom_arm = get_node("../../World/Car/BoomArm")

	debug_camera = get_node("../../World/Arena/Camera2D")

func _physics_process(_delta):
	if debug:
		print(debug_camera.global_position)
		print(debug_camera.zoom)
		material.set_shader_parameter("our_camera_position", debug_camera.global_position)
		material.set_shader_parameter("our_camera_zoom", debug_camera.zoom)
	else:
		material.set_shader_parameter("our_camera_position", boom_arm.camera.global_position)
		material.set_shader_parameter("our_camera_zoom", boom_arm.camera.zoom)
