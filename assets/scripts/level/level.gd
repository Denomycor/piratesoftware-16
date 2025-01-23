class_name Level extends Node

@export var overlay: Overlay
@export var stats: Node
@export var car: Car

signal level_exited(level: Node)


func quit_level() -> void:
	level_exited.emit(self)
