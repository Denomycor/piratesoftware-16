class_name WeaponBar extends HBoxContainer

@export var slots: Array[WeaponSlot]

var current_slot: WeaponSlot

func change_slot(idx: int) -> void:
	if current_slot!=null:
		current_slot.highlight(false)
	current_slot = slots[idx]
	current_slot.highlight(true)
