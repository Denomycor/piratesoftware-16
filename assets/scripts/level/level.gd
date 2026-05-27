class_name Level extends Node

@export var overlay: Overlay
@export var stats: Stats
@export var car: Car
@export var arena: Arena
## Exposed so projectile-spawning scripts can use LevelContext.level.world
## instead of the fragile get_node("World") string lookup.
@onready var world: Node2D = $World

@onready var pause_menu: PauseMenu = $PauseMenu
@onready var game_over_menu: GameOverMenu = $GameOverMenu
@onready var victory_menu: VictoryMenu = $VictoryMenu
@onready var _enemy_spawner: Node = $World/EnemySpawner

signal level_exited(level: Node)

func _ready() -> void:
	# Wire pause / game-over / victory menus.
	pause_menu.quit_level.connect(quit_level)
	game_over_menu.quit_level.connect(quit_level)
	victory_menu.quit_level.connect(quit_level)

	# Wire Stats signals → UI.
	stats.points_changed.connect(overlay.set_points)
	stats.kills_changed.connect(overlay.set_kills)
	stats.speed_changed.connect(overlay.set_speed)
	stats.victory_reached.connect(set_victory)

	# Wire Car signals → Level and Overlay.
	car.health_changed.connect(overlay.set_hp)
	car.game_over_requested.connect(set_game_over)

	# Wire WeaponDock slot-change signal → Overlay.
	car.weapon_dock.weapon_slot_changed.connect(overlay.switch_weapon)

	# Wire enemy-died signal → Stats (scoring stays in Stats domain).
	_enemy_spawner.enemy_died.connect(func(points: int):
		stats.increment_kills()
		stats.add_points(points)
	)

	# Initialize Overlay with car max health and starting weapon slot.
	overlay.setup(car.max_health, 0)

	get_viewport().set_canvas_cull_mask_bit(9, false)
	$game_music.play()
	# Apply any unlocked skill effects to the car before gameplay starts.
	ProgressionManager.apply_skills_to_car(car)


func quit_level() -> void:
	stats.is_game_over = true
	level_exited.emit(self)


func set_game_over() -> void:
	get_tree().paused = true
	stats.is_game_over = true
	pause_menu.queue_free()
	var snapped_time := snappedf(stats.time_survived, 0.01)
	var xp := ProgressionManager.award_run_xp(stats.kills, snapped_time)
	game_over_menu.set_stats(int(stats.points), snapped_time, stats.kills, stats.max_speed, snappedf(stats.max_drift_duration, 0.01), xp)
	game_over_menu.show_game_over_menu()


func set_victory() -> void:
	get_tree().paused = true
	stats.is_game_over = true
	pause_menu.queue_free()
	var snapped_time := snappedf(stats.time_survived, 0.01)
	var xp := ProgressionManager.award_run_xp(stats.kills, snapped_time)
	victory_menu.set_stats(int(stats.points), snapped_time, stats.kills, stats.max_speed, snappedf(stats.max_drift_duration, 0.01), xp)
	victory_menu.show_victory_menu()
