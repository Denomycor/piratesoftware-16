class_name WeaponDock extends Node2D


signal weapon_switched


var current_idx: int


func _ready() -> void:
	get_weapon(0).activate()


func switch_active_weapon(idx: int) -> void:
	print(idx)
	get_weapon(current_idx).deactivate()
	get_weapon(idx).activate()
	current_idx = idx
	weapon_switched.emit()


func get_current_weapon() -> Weapon:
	return get_child(current_idx)


func get_weapon(idx: int) -> Weapon:
	return get_child(idx)


func _input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		var e := event as InputEventMouseButton
		if(e.button_index == MOUSE_BUTTON_WHEEL_DOWN && e.pressed):
			switch_active_weapon(wrapi(current_idx+1, 0, get_child_count()))
		elif(e.button_index == MOUSE_BUTTON_WHEEL_UP && e.pressed):
			switch_active_weapon(wrapi(current_idx-1, 0, get_child_count()))

