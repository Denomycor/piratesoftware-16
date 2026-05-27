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

## Dynamically-built container for active boost timer rows (top-center of screen).
var _boost_container: VBoxContainer
## boost_id (StringName) → Label node showing "Name  X.Xs"
var _boost_labels: Dictionary = {}
## Maximum HP for the vignette gradient — set by Level via setup().
var _max_hp: float = 100.0

func _ready() -> void:
	var ui_scale := GameOptions.ui_scale
	scale_ui(ui_scale)

	# Build the boost timer strip at the top-center of the screen.
	_boost_container = VBoxContainer.new()
	_boost_container.anchor_left   = 0.5
	_boost_container.anchor_right  = 0.5
	_boost_container.anchor_top    = 0.0
	_boost_container.anchor_bottom = 0.0
	_boost_container.offset_left   = -120.0
	_boost_container.offset_top    =   8.0
	_boost_container.offset_right  =  120.0
	_boost_container.alignment     = BoxContainer.ALIGNMENT_CENTER
	add_child(_boost_container)

## Called by Level._ready() to initialize max HP and the first active weapon slot.
func setup(max_health: float, initial_weapon_idx: int) -> void:
	_max_hp = max_health
	health_bar.setup(max_health)
	set_hp(max_health)
	switch_weapon(initial_weapon_idx)

func set_points(points: int) -> void:
	point_counter.text = "Points: " + str(points)

func set_kills(kills: int) -> void:
	kills_counter.text = "Kills: " + str(kills)

func set_speed(speed: float) -> void:
	speedometer.set_speed(speed)

func set_hp(hp: float) -> void:
	vignette.material.set_shader_parameter("inner_radius", lerpf(0, 1, hp / _max_hp))
	health_bar.set_hp(hp)

func switch_weapon(idx: int) -> void:
	weapon_bar.change_slot(idx)

func scale_ui(ui_scale: float) -> void:
	stats.scale = Vector2(ui_scale, ui_scale)
	bar_container.scale = Vector2(ui_scale, ui_scale)
	sonar_container.scale = Vector2(ui_scale, ui_scale)


## Add a new timer row for the given boost.
func add_boost_display(id: StringName, boost_name: String, color: Color, _duration: float) -> void:
	if _boost_labels.has(id):
		return  # already displayed
	var lbl := Label.new()
	lbl.text = boost_name + "  --.-s"
	lbl.add_theme_color_override("font_color", color)
	lbl.add_theme_constant_override("outline_size", 6)
	lbl.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.05, 1.0))
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boost_container.add_child(lbl)
	_boost_labels[id] = lbl


## Update the remaining-time text for the given boost row.
func update_boost_timer(id: StringName, remaining: float, _duration: float) -> void:
	if not _boost_labels.has(id):
		return
	var lbl: Label = _boost_labels[id]
	if not is_instance_valid(lbl):
		return
	# Extract the name prefix (everything before the two spaces we appended).
	var parts: PackedStringArray = lbl.text.split("  ", false)
	var prefix: String = parts[0] if parts.size() > 0 else ""
	lbl.text = prefix + "  " + ("%.1f" % maxf(remaining, 0.0)) + "s"


## Remove the timer row for the given boost.
func remove_boost_display(id: StringName) -> void:
	if not _boost_labels.has(id):
		return
	var lbl: Label = _boost_labels[id]
	if is_instance_valid(lbl):
		lbl.queue_free()
	_boost_labels.erase(id)
