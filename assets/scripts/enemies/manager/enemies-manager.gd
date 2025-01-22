extends Node

@export var target: RigidBody2D
@export var num_groups: int = 10

@onready var spawn_timer: Timer = $SpawnTimer


var crawler_scene = load("res://assets/scenes/enemies/crawler.tscn")

var cur_group = 0

func _ready() -> void:
	spawn_timer.start()
	spawn_timer.timeout.connect(_spawn_enemy)
	
func update_enemies():
	cur_group = cur_group % num_groups

	var enemies = get_tree().get_nodes_in_group("enemies")

	for i in range(len(enemies)):
		if i % num_groups == cur_group:
			enemies[i].update_movement()

	cur_group += 1


func _process(_delta: float) -> void:
	update_enemies()


func _spawn_enemy() -> void:
	var pos = Vector2.ZERO
	var enemy_instance = crawler_scene.instantiate()
	enemy_instance.target = target
	enemy_instance.global_position = pos
	add_child(enemy_instance)
