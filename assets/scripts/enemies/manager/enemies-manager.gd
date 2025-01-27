extends Node

@export var target: RigidBody2D
@export var num_groups: int = 10

@export var max_distance: float = 20000
@export var teleport_distance: float = 20000

@export var max_enemies: int = 100

@onready var spawn_timer: Timer = $SpawnTimer


var crawler_scene: PackedScene = preload("res://assets/scenes/enemies/crawler.tscn")
var biker_scene: PackedScene = preload("res://assets/scenes/enemies/biker.tscn")

var cur_group = 0

func _ready() -> void:
	spawn_timer.start()
	spawn_timer.timeout.connect(_spawn_enemy)
	
func _update_enemies():
	cur_group = cur_group % num_groups

	var enemies = _get_enemies()

	for i in range(enemies.size()):
		if i % num_groups == cur_group:
			if enemies[i].position.distance_to(target.position) > max_distance:
				_teleport_enemy(enemies[i])

			enemies[i].update_movement()

	cur_group += 1


func _teleport_enemy(enemy: Enemy) -> void:
	var target_dir = target.linear_velocity.normalized()
	var teleport_dir = Vector2(randf() - 0.5, randf() - 0.5).normalized()

	if target_dir.dot(teleport_dir) < 0:
		teleport_dir = -teleport_dir

	enemy.position = target.position + teleport_dir * teleport_distance


func _process(_delta: float) -> void:
	_update_enemies()


func _spawn_enemy() -> void:
	if _get_enemies().size() >= max_enemies:
		return
	
	var pos = Vector2.ZERO
	var enemy_instance = biker_scene.instantiate()
	enemy_instance.target = target
	enemy_instance.global_position = pos
	add_child(enemy_instance)


func _get_enemies() -> Array:
	return get_tree().get_nodes_in_group("enemies")
