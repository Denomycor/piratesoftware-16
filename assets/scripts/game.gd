class_name Game extends Node


const TEST_LEVEL: PackedScene = preload("res://assets/scenes/levels/test_level.tscn")

@onready var main_menu: CanvasLayer = $main_menu


func _ready() -> void:
	main_menu.get_node("%play").pressed.connect(switch_main_menu_to_level.bind(TEST_LEVEL))
	main_menu.get_node("%quit").pressed.connect(get_tree().quit)


func switch_main_menu_to_level(level_scene: PackedScene) -> void:
	var level: Level = level_scene.instantiate()
	level.level_exited.connect(switch_level_to_main_menu)
	add_child(level)
	main_menu.visible = false


func switch_level_to_main_menu(level: Node) -> void:
	level.queue_free()
	get_tree().paused = false
	main_menu.visible = true

