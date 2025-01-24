class_name Weapon extends Node2D


@warning_ignore("unused_signal")
signal fired
signal activated
signal deactivated

var active := false


func _ready() -> void:
	visible = false


func activate() -> void:
	visible = true
	active = true
	activated.emit()


func deactivate() -> void:
	visible = false
	active = false
	deactivated.emit()

	
