class_name Game extends Node


@onready var main_menu: CanvasLayer = $main_menu
@onready var tutorial: Tutorial = $tutorial
@onready var loading_screen: LoadingScreen = $loading_screen

## Holds the packed scene once async loading completes; used when the tutorial is dismissed.
var _loaded_scene: PackedScene


func _ready() -> void:
	main_menu.get_node("%play").pressed.connect(show_tutorial)
	main_menu.get_node("%quit").pressed.connect(get_tree().quit)


func show_tutorial() -> void:
	main_menu.visible = false
	main_menu.get_node("%ambience").stop()

	# Connect play signal BEFORE starting, so it fires even if loading finishes instantly
	tutorial.play.connect(_on_tutorial_dismissed, CONNECT_ONE_SHOT)

	# Forward loading progress into the tutorial's bar
	loading_screen.progress_updated.connect(tutorial.set_progress)

	# Start loading headlessly (tutorial provides the visible progress bar)
	loading_screen.loading_complete.connect(_on_loading_complete, CONNECT_ONE_SHOT)
	loading_screen.start_loading("res://assets/scenes/levels/test_level.tscn", false)

	tutorial.start()


func _on_loading_complete(packed_scene: PackedScene) -> void:
	_loaded_scene = packed_scene
	loading_screen.progress_updated.disconnect(tutorial.set_progress)
	tutorial.enable_skip()


func _on_tutorial_dismissed() -> void:
	tutorial.visible = false
	_instantiate_level(_loaded_scene)


func _instantiate_level(packed_scene: PackedScene) -> void:
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
