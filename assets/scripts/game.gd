class_name Game extends Node


const TEST_LEVEL: PackedScene = preload("res://assets/scenes/levels/test_level.tscn")

@onready var main_menu: CanvasLayer = $main_menu
@onready var tutorial: Tutorial = $tutorial


func _ready() -> void:
	main_menu.get_node("%play").pressed.connect(show_tutorial)
	main_menu.get_node("%quit").pressed.connect(get_tree().quit)


func switch_main_menu_to_level() -> void:
	tutorial.visible = false
	tutorial.play.disconnect(switch_main_menu_to_level)
	var level: Level = TEST_LEVEL.instantiate()
	LevelContext.level = level
	level.level_exited.connect(switch_level_to_main_menu)
	main_menu.visible = false
	add_child(level)
	main_menu.get_node("%ambience").stop()
	get_tree().paused = false


func switch_level_to_main_menu(level: Node) -> void:
	level.queue_free()
	LevelContext.set_deferred("level", null)
	main_menu.get_node("%ambience").play()
	main_menu.visible = true

func show_tutorial() -> void:
	tutorial.start()
	tutorial.play.connect(switch_main_menu_to_level)