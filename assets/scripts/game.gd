class_name Game extends Node


@onready var main_menu: CanvasLayer = $main_menu
@onready var tutorial: Tutorial = $tutorial
@onready var loading_screen: LoadingScreen = $loading_screen


func _ready() -> void:
	main_menu.get_node("%play").pressed.connect(show_tutorial)
	main_menu.get_node("%quit").pressed.connect(get_tree().quit)


func show_tutorial() -> void:
	tutorial.start()
	tutorial.play.connect(switch_main_menu_to_level)


## Hides the menu/tutorial and starts async loading of the level.
## The level is NOT instantiated here — _on_level_loaded() does that once
## loading + shader warmup are complete.
func switch_main_menu_to_level() -> void:
	tutorial.visible = false
	tutorial.play.disconnect(switch_main_menu_to_level)
	main_menu.visible = false
	main_menu.get_node("%ambience").stop()
	loading_screen.loading_complete.connect(_on_level_loaded, CONNECT_ONE_SHOT)
	loading_screen.start_loading("res://assets/scenes/levels/test_level.tscn")


func _on_level_loaded(packed_scene: PackedScene) -> void:
	var level: Level = packed_scene.instantiate()
	LevelContext.level = level
	level.level_exited.connect(switch_level_to_main_menu)
	add_child(level)
	get_tree().paused = false


func switch_level_to_main_menu(level: Node) -> void:
	level.queue_free()
	LevelContext.set_deferred("level", null)
	main_menu.get_node("%ambience").play()
	main_menu.visible = true
