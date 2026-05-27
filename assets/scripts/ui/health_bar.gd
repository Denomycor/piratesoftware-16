class_name HealthBar extends TextureProgressBar

## Called by Overlay.setup() to initialize the max value from the car's max_health.
func setup(max_health: float) -> void:
	max_value = max_health
	value = max_value

func set_hp(hp: float) -> void:
	value = clampf(hp, 0, max_value)
