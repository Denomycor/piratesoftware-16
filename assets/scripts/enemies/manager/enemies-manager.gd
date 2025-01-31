extends Node

const BLOCK_RADIUS: float = 200

@export var target: RigidBody2D
@export var num_groups: int = 10

@export var max_distance: float = 25000
@export var teleport_distance: float = 20000


@export var enemy_list: Array[PackedScene]
@export var enemy_ratios: Array[Curve]
@export var max_enemies: Curve

@export var time_for_max_difficulty : float = 60*5
@export var repair_point_interval : float = 10000
@export var repair_distance: float = 5000

@onready var spawn_timer: Timer = $SpawnTimer

var repair_count: int = 0
var difficulty: float = 0
var repair_scene: PackedScene = preload("res://assets/scenes/props/repair.tscn")

var cur_group = 0

func _ready() -> void:
	spawn_timer.start()
	spawn_timer.timeout.connect(_spawn_enemy)

	if enemy_list.size() != enemy_ratios.size():
		printerr("Enemy list and enemy_ratios must have the same size")
		get_tree().quit()
	
func _update_enemies():
	cur_group = cur_group % num_groups

	var enemies = _get_enemies()

	for i in range(enemies.size()):
		if i % num_groups == cur_group:
			if enemies[i].position.distance_to(target.position) > max_distance:
				enemies[i].global_position = _position_near_target(teleport_distance)

			enemies[i].update_movement()

	cur_group += 1


func _position_near_target(distance: float) -> Vector2:
	var arena := LevelContext.level.arena
	var position_dir = Vector2(randf() - 0.5, randf() - 0.5).normalized()
	
	var pos = target.position + position_dir * distance

	while not arena.can_place(BLOCK_RADIUS, pos):
		position_dir = Vector2(randf() - 0.5, randf() - 0.5).normalized()
		
		pos = target.position + position_dir * distance
	
	return pos


func _physics_process(_delta: float) -> void:
	difficulty = clampf(LevelContext.level.stats.time_survived/time_for_max_difficulty, 0, 1)
	_update_enemies()

	if LevelContext.level.stats.points >= repair_point_interval * repair_count:
		spawn_repair()
		repair_count += 1


func _get_random_enemy() -> Enemy:
	if enemy_list.size() == 0:
		return null
	var sum := 0.0
	var ratios: Array[float]
	for ratio in enemy_ratios:
		ratios.append(ratio.sample(difficulty))
	for amount in ratios:
		sum += amount
	var num := randf_range(0,sum)
	sum = 0
	var idx := 0
	while sum < num && idx < enemy_list.size():
		sum += ratios[idx]
		idx += 1
	return enemy_list[idx-1].instantiate()

func _spawn_enemy() -> void:
	if _get_enemies().size() >= int(max_enemies.sample(difficulty)):
		return
	
	var pos = _position_near_target(teleport_distance)
	var enemy_instance = _get_random_enemy()
	

	enemy_instance.target = target
	enemy_instance.global_position = pos
	add_child(enemy_instance)


func _get_enemies() -> Array:
	return get_tree().get_nodes_in_group("enemies")

func spawn_repair() -> void:
	var repair: Repair = repair_scene.instantiate()
	repair.global_position = _position_near_target(repair_distance)
	add_child(repair)
	print(repair.global_position)