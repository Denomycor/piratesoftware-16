extends Node

const BLOCK_RADIUS: float = 200
## Maximum attempts to find a valid off-screen spawn position before
## falling back to a random point inside the arena polygon.
const MAX_SPAWN_RETRIES: int = 30
## Minimum world-space distance from the player for fallback spawn positions.
const MIN_PLAYER_DISTANCE: float = 3000.0
## Spawn interval at difficulty 0 (slow early game).
const SPAWN_INTERVAL_MAX: float = 0.2
## Spawn interval at difficulty 1 (fast late game).
const SPAWN_INTERVAL_MIN: float = 0.1

## Emitted when an enemy dies. Level wires this to Stats so scoring stays
## in the Stats domain, not here.
signal enemy_died(points: int)

@export var target: RigidBody2D
@export var num_groups: int = 10
## Direct reference to Stats for reading time_survived and points thresholds.
## Set via inspector (wired in test_level.tscn).
@export var stats: Stats

@export var max_distance: float = 25000
@export var teleport_distance: float = 20000

@export var enemy_list: Array[PackedScene]
@export var enemy_ratios: Array[Curve]
@export var max_enemies: Curve

@export var time_for_max_difficulty: float = 60 * 15
@export var repair_point_interval: float = 10000
@export var repair_distance: float = 5000
@export var camera: Camera2D

@onready var spawn_timer: Timer = $SpawnTimer

var repair_count: int = 0
var difficulty: float = 0
var repair_scene: PackedScene = preload("res://assets/scenes/props/repair.tscn")

## Chance (0–1) that a dying enemy drops a random boost pickup.
const BOOST_DROP_CHANCE: float = 0.05
## GDScript classes for each droppable boost type (no PackedScene needed).
var _boost_classes: Array = [TwoPointsBoost, ImmunityBoost, AuraBoost]

var cur_group: int = 0

## Cached list of live enemies.
## Using get_nodes_in_group() allocates a new Array every physics frame,
## which generates significant GC pressure at 100+ enemies.
## Instead we track additions in _spawn_enemy() and removals via tree_exiting.
var _enemies: Array = []


func _ready() -> void:
	spawn_timer.start()
	spawn_timer.timeout.connect(_spawn_enemy)

	if enemy_list.size() != enemy_ratios.size():
		printerr("Enemy list and enemy_ratios must have the same size")
		get_tree().quit()


func _update_enemies() -> void:
	cur_group = cur_group % num_groups

	for i: int in range(_enemies.size()):
		if i % num_groups == cur_group:
			if _enemies[i].position.distance_to(target.position) > max_distance:
				_enemies[i].global_position = _position_near_target(teleport_distance)
			_enemies[i].update_movement()

	cur_group += 1


func _get_camera() -> Camera2D:
	if is_instance_valid(camera):
		return camera
	# Fallback: legacy path lookup until scene is wired in inspector
	return LevelContext.level.get_node_or_null("World/Car/BoomArm/Camera2D") as Camera2D


## Returns true if the world-space point falls inside the player's current viewport.
## Used to reject spawn positions that would pop in visibly on screen.
func _is_in_viewport(pos: Vector2) -> bool:
	var cam := _get_camera()
	if not is_instance_valid(cam):
		return false
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var world_size: Vector2 = viewport_size / cam.zoom
	var cam_center: Vector2 = cam.get_screen_center_position()
	return Rect2(cam_center - world_size * 0.5, world_size).has_point(pos)


func _position_near_target(distance: float) -> Vector2:
	var arena := LevelContext.level.arena
	var position_dir := Vector2(randf() - 0.5, randf() - 0.5).normalized()
	var pos := target.position + position_dir * distance

	var retries := 0
	while not arena.can_place(BLOCK_RADIUS, pos) or _is_in_viewport(pos):
		if retries >= MAX_SPAWN_RETRIES:
			pos = _fallback_spawn_position()
			break
		position_dir = Vector2(randf() - 0.5, randf() - 0.5).normalized()
		pos = target.position + position_dir * distance
		retries += 1

	return pos


## Fallback when _position_near_target() exhausts retries.
## Picks a random point inside the arena polygon and checks for minimum
## player distance to avoid spawning directly on top of the car.
func _fallback_spawn_position() -> Vector2:
	var arena := LevelContext.level.arena
	var pos := arena.get_random_free_point_inside_polygon(BLOCK_RADIUS)
	for _i: int in range(5):
		if pos.distance_to(target.position) >= MIN_PLAYER_DISTANCE and not _is_in_viewport(pos):
			break
		pos = arena.get_random_free_point_inside_polygon(BLOCK_RADIUS)
	return pos


func _physics_process(_delta: float) -> void:
	if is_instance_valid(stats):
		difficulty = clampf(stats.time_survived / time_for_max_difficulty, 0, 1)
		if stats.points >= repair_point_interval * repair_count:
			spawn_repair()
			repair_count += 1
	_update_enemies()


func _get_random_enemy() -> Enemy:
	if enemy_list.size() == 0:
		return null
	var sum := 0.0
	var ratios: Array[float] = []
	for ratio: Curve in enemy_ratios:
		ratios.append(ratio.sample(difficulty))
	for amount: float in ratios:
		sum += amount
	var num := randf_range(0, sum)
	sum = 0.0
	var idx := 0
	while sum < num && idx < enemy_list.size():
		sum += ratios[idx]
		idx += 1
	return enemy_list[idx - 1].instantiate()


func _spawn_enemy() -> void:
	# Scale spawn interval with difficulty: faster spawns as the run progresses.
	spawn_timer.wait_time = lerpf(SPAWN_INTERVAL_MAX, SPAWN_INTERVAL_MIN, difficulty)

	if _enemies.size() >= int(max_enemies.sample(difficulty)):
		return

	var pos := _position_near_target(teleport_distance)
	var enemy_instance := _get_random_enemy()

	enemy_instance.target = target
	enemy_instance.global_position = pos

	# Remove from cache when the enemy leaves the tree (death, queue_free, etc.)
	enemy_instance.tree_exiting.connect(func(): _enemies.erase(enemy_instance))
	# Try to drop a boost at the enemy's position when it dies.
	enemy_instance.died.connect(func(): _try_drop_boost(enemy_instance.global_position))
	# Notify Level (and through it Stats) that an enemy died.
	enemy_instance.died.connect(func(): enemy_died.emit(enemy_instance.points))

	_enemies.append(enemy_instance)
	add_child(enemy_instance)


## Rolls a chance to drop a random boost at the given world position.
## Called from the dying enemy's `died` signal.
func _try_drop_boost(pos: Vector2) -> void:
	if randf() >= BOOST_DROP_CHANCE:
		return
	var script: GDScript = _boost_classes[randi() % _boost_classes.size()]
	var boost: BoostPickup = script.new()
	boost.global_position = pos
	add_child(boost)


func spawn_repair() -> void:
	var repair: Repair = repair_scene.instantiate()
	repair.global_position = _position_near_target(repair_distance)
	add_child(repair)
