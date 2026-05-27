extends ColorRect

## Wire these in the test_level.tscn inspector (CanvasLayer/ColorRect node).
@export var boom_arm: BoomArm
@export var debug_camera: Camera2D

var debug := false

func _physics_process(_delta: float) -> void:
	if debug:
		material.set_shader_parameter("our_camera_position", debug_camera.global_position)
		material.set_shader_parameter("our_camera_zoom", debug_camera.zoom)
	else:
		material.set_shader_parameter("our_camera_position", boom_arm.camera.global_position)
		material.set_shader_parameter("our_camera_zoom", boom_arm.camera.zoom)
		material.set_shader_parameter("our_resolution", get_viewport_rect().size)
