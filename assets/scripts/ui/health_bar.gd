class_name HealthBar extends TextureProgressBar

func _ready():
	max_value = owner.get_parent().car.max_health
	value = max_value

func set_hp(hp: float) -> void:
	value = clampf(hp, 0, max_value)
