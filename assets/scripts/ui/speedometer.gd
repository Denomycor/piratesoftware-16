class_name Speedometer extends TextureRect

@onready var pointer = $Container/PointerSprite
@onready var glass = $Glass

@export var max_speed := 300

const MAX_ROTATION := 25
const MIN_ROTATION := -125

func set_speed(speed: float) -> void:
	var percent_speed = speed / max_speed

	pointer.rotation = deg_to_rad(clampf(lerpf(MIN_ROTATION, MAX_ROTATION, 1 - percent_speed), MIN_ROTATION, MAX_ROTATION))

	if percent_speed > 0.7:
		var normalized_percent_speed = (percent_speed - 0.7) / 0.3
		glass.modulate = Color(normalized_percent_speed, 0, 0, 1)
	else:
		glass.modulate = Color(1, 1, 1, 1)
