class_name SpeedPointer extends Sprite2D

@export var max_speed := 300

const MAX_ROTATION := 25
const MIN_ROTATION := -125

func set_speed(speed: float) -> void:
	rotation = deg_to_rad(clampf(lerpf(MIN_ROTATION, MAX_ROTATION, 1-speed/max_speed), MIN_ROTATION, MAX_ROTATION))