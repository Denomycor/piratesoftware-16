extends Node

const BLOCK_RADIUS: float = 200

@export var target: RigidBody2D
@export var num_groups: int = 10

@export var max_distance: float = 25000
@export var teleport_distance: float = 20000


@export var enemy_list: Array[PackedScene]
@export var enemy_ratios: Array[float]
@export var max_enemies: int = 500

@onready var spawn_timer: Timer = $SpawnTimer


var cur_group = 0

func _ready() -> void:
	spawn_timer.start()
	spawn_timer.timeout.connect(_spawn_enemy)

	if enemy_list.size() != enemy_ratios.size():
		printerr("Enemy list and ratios must have the same size")
		get_tree().quit()
	
func _update_enemies():
	cur_group = cur_group % num_groups

	var enemies = _get_enemies()

	for i in range(enemies.size()):
		if i % num_groups == cur_group:
			if enemies[i].position.distance_to(target.position) > max_distance:
				enemies[i].global_position = _position_near_target()

			enemies[i].update_movement()

	cur_group += 1


func _position_near_target() -> Vector2:
	var arena := LevelContext.level.arena
	var target_dir = target.linear_velocity.normalized()
	var position_dir = Vector2(randf() - 0.5, randf() - 0.5).normalized()

	if target_dir.dot(position_dir) < 0:
		position_dir = -position_dir
	
	var pos = target.position + position_dir * teleport_distance

	while not arena.can_place(BLOCK_RADIUS, pos):
		position_dir = Vector2(randf() - 0.5, randf() - 0.5).normalized()

		if target_dir.dot(position_dir) < 0:
			position_dir = -position_dir
		
		pos = target.position + position_dir * teleport_distance
	
	return pos


func _process(_delta: float) -> void:
	_update_enemies()


func _get_random_enemy() -> PackedScene:
	var ratio = randf()
	var sum := 0.0

	for i in enemy_ratios.size():
		sum += enemy_ratios[i]
		if ratio < sum:
			return enemy_list[i]
			
	return enemy_list[enemy_list.size() - 1]

func _spawn_enemy() -> void:
	if _get_enemies().size() >= max_enemies:
		return
	
	var pos = _position_near_target()
	var enemy_instance = _get_random_enemy().instantiate()
	

	enemy_instance.target = target
	enemy_instance.global_position = pos
	add_child(enemy_instance)


func _get_enemies() -> Array:
	return get_tree().get_nodes_in_group("enemies")
