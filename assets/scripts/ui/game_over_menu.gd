class_name GameOverMenu extends CanvasLayer

signal quit_level

func _ready() -> void:
	visible = false
	%quit.pressed.connect(quit_level.emit)

func show_game_over_menu() -> void:
	visible = true
	%explode.play()

func set_stats(points: int, time_survived: float, kills: int, max_speed: float, max_drift_duration: float) -> void:
	%Points.text = str(points)
	%TimeSurvived.text = str(time_survived)
	%Kills.text = str(kills)
	%MaxSpeed.text = str(max_speed)
	%MaxDriftDuration.text = str(max_drift_duration)

