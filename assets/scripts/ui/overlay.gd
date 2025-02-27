class_name Overlay extends CanvasLayer

@onready var point_counter: Label = %Points
@onready var kills_counter: Label = %Kills
@onready var speedometer: Speedometer = $BarContainer/HBoxContainer/Speedometer
@onready var health_bar: HealthBar = $BarContainer/HBoxContainer/VBoxContainer/Panel2/TextureRect/ProgressBar
@onready var weapon_bar: WeaponBar = $BarContainer/HBoxContainer/VBoxContainer/Panel/TextureRect/WeaponBar
@onready var vignette: ColorRect = $ColorRect

@onready var stats: VBoxContainer = $StatsContainer
@onready var bar_container: CenterContainer = $BarContainer
@onready var sonar_container: HBoxContainer = $SonarContainer

func _ready() -> void:
	var ui_scale = GameOptions.ui_scale
	scale_ui(ui_scale)
		
func set_points(points: int) -> void:
	point_counter.text = "Points: " + str(points)

func set_kills(kills: int) -> void:
	kills_counter.text = "Kills: " + str(kills)

func set_speed(speed: float) -> void:
	speedometer.set_speed(speed)

func set_hp(hp: float) -> void:
	vignette.material.set_shader_parameter("inner_radius", lerpf(0, 1, hp / LevelContext.level.car.max_health))
	health_bar.set_hp(hp)

func switch_weapon(idx: int) -> void:
	weapon_bar.change_slot(idx)

func scale_ui(ui_scale: float) -> void:
	stats.scale = Vector2(ui_scale, ui_scale)
	bar_container.scale = Vector2(ui_scale, ui_scale)
	sonar_container.scale = Vector2(ui_scale, ui_scale)
