## Skill-tree / progression screen.
## Embedded as tab 3 in MainMenu's TabContainer (main_menu.tscn).
## All child nodes are built programmatically; the .tscn only needs the root
## VBoxContainer with this script attached.
##
## Call refresh() whenever the tab becomes visible to update displayed values.
class_name ProgressionScreen extends VBoxContainer

signal back_pressed

# References to dynamically-created data labels and skill containers.
var _alien_level_lbl:    Label
var _alien_xp_lbl:       Label
var _alien_pts_lbl:      Label
var _alien_skills_box:   VBoxContainer

var _car_level_lbl:      Label
var _car_xp_lbl:         Label
var _car_pts_lbl:        Label
var _car_skills_box:     VBoxContainer


func _ready() -> void:
	theme = load("res://assets/resources/theme.tres")
	_build_ui()
	refresh()


# ------------------------------------------------------------------ UI build

func _build_ui() -> void:
	add_theme_constant_override("separation", 12)

	# Title
	var title := Label.new()
	title.text = "PROGRESSION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	add_child(title)

	# Inner tab container (Alien / Car)
	var tabs := TabContainer.new()
	tabs.size_flags_vertical = SIZE_EXPAND_FILL
	tabs.tab_alignment = TabBar.ALIGNMENT_CENTER
	add_child(tabs)

	tabs.add_child(_build_track_tab("Alien", SkillNode.Track.ALIEN))
	tabs.add_child(_build_track_tab("Car",   SkillNode.Track.CAR))

	# Back button
	var back_btn := Button.new()
	back_btn.text = "Back"
	back_btn.size_flags_horizontal = SIZE_SHRINK_CENTER
	back_btn.pressed.connect(back_pressed.emit)
	add_child(back_btn)


func _build_track_tab(tab_label: String, track: SkillNode.Track) -> VBoxContainer:
	var container := VBoxContainer.new()
	container.name = tab_label
	container.add_theme_constant_override("separation", 8)

	# --- Level + XP info ---
	var level_lbl := Label.new()
	level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_lbl.add_theme_font_size_override("font_size", 22)
	container.add_child(level_lbl)

	var xp_lbl := Label.new()
	xp_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	container.add_child(xp_lbl)

	var pts_lbl := Label.new()
	pts_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pts_lbl.add_theme_font_size_override("font_size", 18)
	container.add_child(pts_lbl)

	container.add_child(HSeparator.new())

	# --- Scrollable skill list ---
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	container.add_child(scroll)

	var skills_vbox := VBoxContainer.new()
	skills_vbox.size_flags_horizontal = SIZE_EXPAND_FILL
	skills_vbox.add_theme_constant_override("separation", 6)
	scroll.add_child(skills_vbox)

	# Store label/container references by track
	if track == SkillNode.Track.ALIEN:
		_alien_level_lbl  = level_lbl
		_alien_xp_lbl     = xp_lbl
		_alien_pts_lbl    = pts_lbl
		_alien_skills_box = skills_vbox
	else:
		_car_level_lbl    = level_lbl
		_car_xp_lbl       = xp_lbl
		_car_pts_lbl      = pts_lbl
		_car_skills_box   = skills_vbox

	return container


# ------------------------------------------------------------------ refresh

## Repopulate all labels and skill buttons from current save data.
## Call whenever the screen becomes visible.
func refresh() -> void:
	_refresh_track(SkillNode.Track.ALIEN)
	_refresh_track(SkillNode.Track.CAR)


func _refresh_track(track: SkillNode.Track) -> void:
	var total_xp:       float
	var level:          int
	var pts:            int
	var level_lbl:      Label
	var xp_lbl:         Label
	var pts_lbl:        Label
	var skills_box:     VBoxContainer

	if track == SkillNode.Track.ALIEN:
		total_xp   = SaveManager.get_alien_xp()
		level      = SaveManager.get_alien_level()
		pts        = SaveManager.get_alien_skill_points()
		level_lbl  = _alien_level_lbl
		xp_lbl     = _alien_xp_lbl
		pts_lbl    = _alien_pts_lbl
		skills_box = _alien_skills_box
	else:
		total_xp   = SaveManager.get_car_xp()
		level      = SaveManager.get_car_level()
		pts        = SaveManager.get_car_skill_points()
		level_lbl  = _car_level_lbl
		xp_lbl     = _car_xp_lbl
		pts_lbl    = _car_pts_lbl
		skills_box = _car_skills_box

	level_lbl.text = "Level %d" % level

	var xp_progress := ProgressionManager.xp_on_current_level(total_xp)
	var xp_needed   := ProgressionManager.xp_for_next_level(level)
	xp_lbl.text  = "XP: %d / %d" % [int(xp_progress), int(xp_needed)]
	pts_lbl.text = "Skill Points available: %d" % pts

	# Clear old skill rows (free immediately — safe from UI code)
	for child in skills_box.get_children():
		child.free()

	# Rebuild skill rows
	for skill_node: SkillNode in ProgressionManager.get_nodes_for_track(track):
		skills_box.add_child(_build_skill_row(skill_node, pts))


func _build_skill_row(skill_node: SkillNode, available_pts: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)

	# Info column (name + description)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = SIZE_EXPAND_FILL

	var name_lbl := Label.new()
	name_lbl.text = skill_node.display_name
	info.add_child(name_lbl)

	var desc_lbl := Label.new()
	desc_lbl.text = skill_node.description
	desc_lbl.add_theme_font_size_override("font_size", 14)
	desc_lbl.modulate = Color(0.75, 0.75, 0.75)
	info.add_child(desc_lbl)

	# Show prerequisites if any are unmet
	if not skill_node.prerequisites.is_empty():
		var prereq_names: Array[String] = []
		for prereq_id: StringName in skill_node.prerequisites:
			var prereq_node := ProgressionManager.get_node_by_id(prereq_id)
			if prereq_node != null:
				prereq_names.append(prereq_node.display_name)
			else:
				prereq_names.append(str(prereq_id))
		var req_lbl := Label.new()
		req_lbl.text = "Requires: " + ", ".join(prereq_names)
		req_lbl.add_theme_font_size_override("font_size", 12)
		req_lbl.modulate = Color(0.6, 0.6, 0.6)
		info.add_child(req_lbl)

	row.add_child(info)

	# Cost label
	var cost_lbl := Label.new()
	cost_lbl.text = "%d pt" % skill_node.cost
	cost_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cost_lbl.custom_minimum_size = Vector2(40, 0)
	row.add_child(cost_lbl)

	# Unlock button
	var btn := Button.new()
	var is_unlocked := SaveManager.is_node_unlocked(skill_node.id)

	var prereqs_met := true
	for prereq: StringName in skill_node.prerequisites:
		if not SaveManager.is_node_unlocked(prereq):
			prereqs_met = false
			break

	if is_unlocked:
		btn.text     = "✓ Unlocked"
		btn.disabled = true
		btn.modulate = Color(0.5, 0.9, 0.5)
	elif not prereqs_met:
		btn.text     = "Locked"
		btn.disabled = true
		btn.modulate = Color(0.6, 0.6, 0.6)
	elif available_pts < skill_node.cost:
		btn.text     = "Unlock"
		btn.disabled = true
		btn.modulate = Color(0.6, 0.6, 0.6)
	else:
		btn.text = "Unlock"
		btn.pressed.connect(func() -> void: _on_unlock_pressed(skill_node))

	row.add_child(btn)

	return row


func _on_unlock_pressed(skill_node: SkillNode) -> void:
	if ProgressionManager.unlock_skill(skill_node):
		refresh()
