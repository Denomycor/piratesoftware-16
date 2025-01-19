class_name Game extends Node


const TEST_LEVEL: PackedScene = preload("res://assets/scenes/levels/test_level.tscn")

@onready var main_menu: CanvasLayer = $main_menu


func _ready() -> void:
	main_menu.get_node("%play").pressed.connect(switch_main_menu_to_level.bind(TEST_LEVEL))


func switch_main_menu_to_level(level_scene: PackedScene) -> void:
	var level := level_scene.instantiate()
	add_child(level)
	main_menu.visible = false


func switch_level_to_main_menu(_level: Node) -> void:
	pass

