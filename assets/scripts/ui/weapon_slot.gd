class_name WeaponSlot extends VBoxContainer

const HIGHLIGHT_COLOR := Color(214.0/255,142.0/255,106.0/255,1)
const NORMAL_COLOR := Color(245.0/255,214.0/255,179.0/255,1)

@export var border: TextureRect
@export var highlighted_border: TextureRect
@export var label: Label

func highlight(state: bool) -> void:
	border.visible = !state
	highlighted_border.visible = state
	if state:
		label.label_settings.font_color = HIGHLIGHT_COLOR
	else:
		label.label_settings.font_color = NORMAL_COLOR
