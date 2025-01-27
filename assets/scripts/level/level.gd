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
	LevelContext.sonar_camera = get_node("Overlay/SubViewportContainer/SubViewport/sonar_camera")
	pause_menu.quit_level.connect(quit_level)
	print(get_viewport().canvas_cull_mask)
	get_viewport().set_canvas_cull_mask_bit(9, false)
	print(get_viewport().canvas_cull_mask)


func quit_level() -> void:
	level_exited.emit(self)


func set_game_over() -> void:
	get_tree().paused = true
	stats.is_game_over = true
	pause_menu.queue_free()
	game_over_menu.set_stats(int(stats.points), stats.time_survived, stats.kills, stats.max_speed, stats.max_drift_duration)
	game_over_menu.show_game_over_menu()

