class_name Overlay extends CanvasLayer

@onready var point_counter: Label = %Points
@onready var kills_counter: Label = %Kills
@export var speed_counter: SpeedPointer
@export var health_bar: HealthBar
@export var weapon_bar: WeaponBar
@export var vignette: ColorRect

func set_points(points: int) -> void:
	point_counter.text = "Points: " + str(points)

func set_kills(kills: int) -> void:
	kills_counter.text = "Kills: " + str(kills)

func set_speed(speed: float) -> void:
	speed_counter.set_speed(speed)

func set_hp(hp: float) -> void:
	vignette.material.set_shader_parameter("inner_radius",lerpf(0, 1, hp/LevelContext.level.car.max_health))
	health_bar.set_hp(hp)

func switch_weapon(idx: int) -> void:
	weapon_bar.change_slot(idx)