class_name Weapon extends Node2D


@warning_ignore("unused_signal")
signal fired
signal activated
signal deactivated


func activate() -> void:
	visible = true
	activated.emit()


func deactivate() -> void:
	visible = false
	deactivated.emit()

