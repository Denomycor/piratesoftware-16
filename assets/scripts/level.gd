class_name Level extends Node


signal level_exited(level: Node)


func quit_level() -> void:
	level_exited.emit(self)
