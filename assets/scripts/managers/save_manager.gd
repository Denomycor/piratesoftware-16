## Autoload singleton — handles JSON persistence for progression data.
##
## Save path: user://save_data.json
## (resolves to %APPDATA%\Godot\app_userdata\piratesoftware-16\ on Windows)
##
## Schema (version 1):
## {
##   "version":           int,
##   "alien_xp":          float,   # cumulative total XP on the alien track
##   "car_xp":            float,   # cumulative total XP on the car track
##   "alien_level":       int,     # derived from alien_xp, stored for quick access
##   "car_level":         int,     # derived from car_xp, stored for quick access
##   "alien_skill_points": int,    # unspent points on the alien track
##   "car_skill_points":  int,     # unspent points on the car track
##   "unlocked_nodes":    Array[String]  # list of skill node id strings
## }
## class_name intentionally omitted: Godot 4.6.3 reports "hides an autoload
## singleton" when class_name matches the autoload name. Access via autoload name.
extends Node

const SAVE_PATH    := "user://save_data.json"
const SAVE_VERSION := 1

var _data: Dictionary = {}

func _ready() -> void:
	load_game()


# ------------------------------------------------------------------ lifecycle

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_data = _default_data()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("SaveManager: cannot open save file for reading — resetting")
		_data = _default_data()
		return
	var text := file.get_as_text()
	file.close()
	var json := JSON.new()
	var err  := json.parse(text)
	if err != OK:
		push_error("SaveManager: JSON parse error — resetting to defaults")
		_data = _default_data()
		return
	_data = json.get_data()
	_migrate()


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: cannot open save file for writing")
		return
	file.store_string(JSON.stringify(_data, "\t"))
	file.close()


func reset_save() -> void:
	_data = _default_data()
	save_game()


# ------------------------------------------------------------------ internals

func _default_data() -> Dictionary:
	return {
		"version":            SAVE_VERSION,
		"alien_xp":           0.0,
		"car_xp":             0.0,
		"alien_level":        0,
		"car_level":          0,
		"alien_skill_points": 0,
		"car_skill_points":   0,
		"unlocked_nodes":     []
	}


## Fill in any keys missing from an older save version.
func _migrate() -> void:
	var defaults := _default_data()
	for key: String in defaults:
		if not _data.has(key):
			_data[key] = defaults[key]
	_data["version"] = SAVE_VERSION


# ------------------------------------------------------------------ getters

func get_alien_xp() -> float:
	return float(_data.get("alien_xp", 0.0))

func get_car_xp() -> float:
	return float(_data.get("car_xp", 0.0))

func get_alien_level() -> int:
	return int(_data.get("alien_level", 0))

func get_car_level() -> int:
	return int(_data.get("car_level", 0))

func get_alien_skill_points() -> int:
	return int(_data.get("alien_skill_points", 0))

func get_car_skill_points() -> int:
	return int(_data.get("car_skill_points", 0))

func get_unlocked_nodes() -> Array:
	return _data.get("unlocked_nodes", [])

func is_node_unlocked(id: StringName) -> bool:
	return str(id) in get_unlocked_nodes()


# ------------------------------------------------------------------ setters

func set_alien_xp(v: float) -> void:
	_data["alien_xp"] = v

func set_car_xp(v: float) -> void:
	_data["car_xp"] = v

func set_alien_level(v: int) -> void:
	_data["alien_level"] = v

func set_car_level(v: int) -> void:
	_data["car_level"] = v

func set_alien_skill_points(v: int) -> void:
	_data["alien_skill_points"] = v

func set_car_skill_points(v: int) -> void:
	_data["car_skill_points"] = v

func unlock_node(id: StringName) -> void:
	if not is_node_unlocked(id):
		_data["unlocked_nodes"].append(str(id))
