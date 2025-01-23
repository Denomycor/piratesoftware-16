class_name Level extends Node

@export var overlay: Overlay
@export var stats: Stats
@export var car: Car

signal level_exited(level: Node)

func _ready():
	LevelContext.level = self
	$PauseMenu.quit_level.connect(quit_level)

func quit_level() -> void:
	level_exited.emit(self)

func set_game_over() -> void:
	get_tree().paused = true
	stats.is_game_over = true
	$PauseMenu.queue_free()
	$GameOverMenu.set_stats(stats.points, stats.time_survived, stats.kills, stats.max_speed, stats.max_drift_duration)
	$GameOverMenu.show_game_over_menu()
