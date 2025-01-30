class_name Level extends Node

@export var overlay: Overlay
@export var stats: Stats
@export var car: Car
@export var arena: Arena

@onready var pause_menu: PauseMenu = $PauseMenu
@onready var game_over_menu: GameOverMenu = $GameOverMenu

signal level_exited(level: Node)

func _ready():
	LevelContext.level = self
	pause_menu.quit_level.connect(quit_level)
	game_over_menu.quit_level.connect(quit_level)
	get_viewport().set_canvas_cull_mask_bit(9, false)
	$game_music.play()


func quit_level() -> void:
	stats.is_game_over = true
	level_exited.emit(self)


func set_game_over() -> void:
	get_tree().paused = true
	stats.is_game_over = true
	pause_menu.queue_free()
	game_over_menu.set_stats(int(stats.points), snappedf(stats.time_survived, 0.01), stats.kills, stats.max_speed, snappedf(stats.max_drift_duration, 0.01))
	game_over_menu.show_game_over_menu()
	