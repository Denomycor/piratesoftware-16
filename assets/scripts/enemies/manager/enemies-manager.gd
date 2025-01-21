extends Node

@export var target: RigidBody2D
@export var num_groups: int = 10

@onready var spawn_timer: Timer = $SpawnTimer


var chaser_scene = load("res://assets/scenes/enemies/chaser.tscn")

var enemies: Array = []
var cur_group = 0

func _ready() -> void:
	spawn_timer.start()
	spawn_timer.timeout.connect(_spawn_enemy)

func remove_enemy(enemy: Node) -> void:
	if enemy in enemies:
		enemies.erase(enemy)
		enemy.queue_free()

	
func update_enemies():
	cur_group = cur_group % num_groups

	print("updating group: ", cur_group)

	for i in range(len(enemies)):
		if i % num_groups == cur_group:
			enemies[i].update_movement()

	cur_group += 1


func _process(_delta: float) -> void:
	update_enemies()


func _spawn_enemy() -> void:
	if target == null:
		print("Target is null")
		return

	var pos = Vector2.ZERO
	var enemy_instance = chaser_scene.instantiate()
	enemy_instance.target = target
	enemy_instance.global_position = pos
	add_child(enemy_instance)
	enemies.append(enemy_instance)