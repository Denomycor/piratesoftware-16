class_name WeaponDock extends Node2D

signal weapon_switched

@onready var weapon_list := $WeaponList
@onready var weapon_anim := $ChangeAnim/Node2D/AnimatedSprite2D
@onready var alien_anim := $ChangeAnim/AnimatedSprite2D


var current_idx: int


func _ready() -> void:
	get_weapon(0).activate()
	weapon_anim.animation_finished.connect(func(): weapon_anim.visible = false)
	alien_anim.animation_finished.connect(func(): alien_anim.visible = false)


func switch_active_weapon(idx: int) -> void:
	get_weapon(current_idx).deactivate()
	get_weapon(idx).activate()
	current_idx = idx
	weapon_switched.emit()


func get_current_weapon() -> Weapon:
	return weapon_list.get_child(current_idx)


func get_weapon(idx: int) -> Weapon:
	return weapon_list.get_child(idx)


func _input(event: InputEvent) -> void:
	if (event is InputEventMouseButton):
		var e := event as InputEventMouseButton
		var idx := 0
		if (e.button_index == MOUSE_BUTTON_WHEEL_DOWN && e.pressed):
			idx = wrapi(current_idx + 1, 0, weapon_list.get_child_count())
			play_change_animation(idx)
		elif (e.button_index == MOUSE_BUTTON_WHEEL_UP && e.pressed):
			idx = wrapi(current_idx - 1, 0, weapon_list.get_child_count())
			play_change_animation(idx)
			
	elif event is InputEventKey and event.pressed:
		var weapon_count = weapon_list.get_child_count()
		var idx := -1
		match event.keycode:
			KEY_1: idx = 0
			KEY_2: idx = 1
			KEY_3: idx = 2
			KEY_4: idx = 3
			KEY_5: idx = 4
		if idx >= 0 and idx < weapon_count:
			play_change_animation(idx)

func play_change_animation(idx: int) -> void:
	weapon_anim.visible = true
	alien_anim.visible = true
	weapon_anim.play()
	alien_anim.play()
	weapon_anim.frame_changed.connect(func():
		print("change")
		if weapon_anim.frame == 2:
			switch_active_weapon(idx)
	)
