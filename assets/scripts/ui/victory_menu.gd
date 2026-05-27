class_name VictoryMenu extends CanvasLayer

signal quit_level

func _ready() -> void:
	visible = false
	%quit.pressed.connect(quit_level.emit)

func show_victory_menu() -> void:
	visible = true

## Called once by Level.set_victory().
## Displays the run summary + XP earned. XP has already been awarded by Level.
func set_stats(points: int, time_survived: float, kills: int, max_speed: float, max_drift_duration: float, xp: Dictionary) -> void:
	%Points.text           = str(points)
	%TimeSurvived.text     = str(time_survived)
	%Kills.text            = str(kills)
	%MaxSpeed.text         = str(max_speed)
	%MaxDriftDuration.text = str(max_drift_duration)

	var alien_lv_str := ""
	if xp.alien_levels_gained > 0:
		alien_lv_str = "  ▲ LEVEL UP → %d" % xp.alien_level
	%AlienXPLabel.text = "+%d XP (Lv.%d%s)" % [int(xp.alien_xp_gained), xp.alien_level, alien_lv_str]

	var car_lv_str := ""
	if xp.car_levels_gained > 0:
		car_lv_str = "  ▲ LEVEL UP → %d" % xp.car_level
	%CarXPLabel.text = "+%d XP (Lv.%d%s)" % [int(xp.car_xp_gained), xp.car_level, car_lv_str]
