## Autoload singleton — XP math, leveling, skill unlock, and skill definitions.
##
## XP sources (M5 scope, unbalanced by design — tune in a later pass):
##   Alien XP = kills * XP_PER_KILL
##   Car XP   = floor(time_survived / 10) * XP_PER_10S
##
## Level curve: advancing from level N to N+1 costs (N+1) * XP_PER_LEVEL.
##   Level 0→1: 100 XP
##   Level 1→2: 200 XP
##   Level 2→3: 300 XP   etc.
##
## Gameplay effects are applied at level start via apply_skills_to_car().
## That method also caches player_damage_multiplier and player_range_multiplier
## so each player weapon can stamp those values onto freshly-spawned projectiles.
## class_name intentionally omitted: in Godot 4.6.3, having class_name match an
## autoload name causes "hides an autoload singleton" parse errors across the project.
## Access this singleton by its autoload name (ProgressionManager.xxx) directly.
extends Node

const XP_PER_KILL  := 10.0
const XP_PER_10S   := 5.0
const XP_PER_LEVEL := 100.0

## All registered skill nodes. Populated in _ready().
var skill_nodes: Array[SkillNode] = []

## Cached per-run multipliers — written by apply_skills_to_car() and read by
## player weapon lambdas each time they spawn a projectile.
## With class_name removed, ProgressionManager resolves unambiguously to the
## autoload instance, so regular instance vars are safe to read externally.
var player_damage_multiplier: float = 1.0
var player_range_multiplier:  float = 1.0


func _ready() -> void:
	_register_skill_nodes()


# ------------------------------------------------------------------ XP math

## XP required to advance from `level` to `level + 1`.
static func xp_for_next_level(level: int) -> float:
	return float(level + 1) * XP_PER_LEVEL


## Current level derived from cumulative total XP.
static func level_from_xp(total_xp: float) -> int:
	var level   := 0
	var remaining := total_xp
	while remaining >= xp_for_next_level(level):
		remaining -= xp_for_next_level(level)
		level     += 1
	return level


## XP accumulated so far toward the *next* level (0 .. xp_for_next_level-1).
static func xp_on_current_level(total_xp: float) -> float:
	var level     := 0
	var remaining := total_xp
	while remaining >= xp_for_next_level(level):
		remaining -= xp_for_next_level(level)
		level     += 1
	return remaining


# ------------------------------------------------------------------ run completion

## Award XP earned during a completed run.
## Updates SaveManager and persists the save.
## Returns a summary dict for display in the game-over screen:
##   alien_xp_gained, car_xp_gained,
##   alien_levels_gained, car_levels_gained,
##   alien_level, car_level,
##   alien_skill_points, car_skill_points
func award_run_xp(kills: int, time_survived: float) -> Dictionary:
	var alien_xp_gained: float = kills * XP_PER_KILL
	var car_xp_gained:   float = floor(time_survived / 10.0) * XP_PER_10S

	var old_alien_level := SaveManager.get_alien_level()
	var old_car_level   := SaveManager.get_car_level()

	var new_alien_xp := SaveManager.get_alien_xp() + alien_xp_gained
	var new_car_xp   := SaveManager.get_car_xp()   + car_xp_gained

	var new_alien_level := level_from_xp(new_alien_xp)
	var new_car_level   := level_from_xp(new_car_xp)

	var alien_levels_gained := new_alien_level - old_alien_level
	var car_levels_gained   := new_car_level   - old_car_level

	SaveManager.set_alien_xp(new_alien_xp)
	SaveManager.set_car_xp(new_car_xp)
	SaveManager.set_alien_level(new_alien_level)
	SaveManager.set_car_level(new_car_level)
	SaveManager.set_alien_skill_points(
		SaveManager.get_alien_skill_points() + alien_levels_gained)
	SaveManager.set_car_skill_points(
		SaveManager.get_car_skill_points() + car_levels_gained)
	SaveManager.save_game()

	return {
		"alien_xp_gained":     alien_xp_gained,
		"car_xp_gained":       car_xp_gained,
		"alien_levels_gained": alien_levels_gained,
		"car_levels_gained":   car_levels_gained,
		"alien_level":         new_alien_level,
		"car_level":           new_car_level,
		"alien_skill_points":  SaveManager.get_alien_skill_points(),
		"car_skill_points":    SaveManager.get_car_skill_points(),
	}


# ------------------------------------------------------------------ skill unlock

## Attempt to spend a skill point to unlock a node.
## Validates: not already unlocked, sufficient points, prerequisites met.
## Saves on success. Returns true if unlocked, false otherwise.
func unlock_skill(node: SkillNode) -> bool:
	if SaveManager.is_node_unlocked(node.id):
		return false

	var pts := SaveManager.get_alien_skill_points() \
		if node.track == SkillNode.Track.ALIEN \
		else SaveManager.get_car_skill_points()
	if pts < node.cost:
		return false

	for prereq: StringName in node.prerequisites:
		if not SaveManager.is_node_unlocked(prereq):
			return false

	if node.track == SkillNode.Track.ALIEN:
		SaveManager.set_alien_skill_points(pts - node.cost)
	else:
		SaveManager.set_car_skill_points(pts - node.cost)
	SaveManager.unlock_node(node.id)
	SaveManager.save_game()
	return true


# ------------------------------------------------------------------ queries

func get_nodes_for_track(track: SkillNode.Track) -> Array[SkillNode]:
	var result: Array[SkillNode] = []
	for node: SkillNode in skill_nodes:
		if node.track == track:
			result.append(node)
	return result


func get_node_by_id(id: StringName) -> SkillNode:
	for node: SkillNode in skill_nodes:
		if node.id == id:
			return node
	return null


# ------------------------------------------------------------------ skill definitions

func _register_skill_nodes() -> void:
	skill_nodes.clear()

	# ---- Alien skills ----
	_add_node(SkillNode.Track.ALIEN, &"alien_sharp_claws",
		"Sharp Claws",     "+10% weapon damage.",
		&"weapon_damage_multiplier", 1.1)

	_add_node(SkillNode.Track.ALIEN, &"alien_battle_hardened",
		"Battle Hardened", "+20 max HP.",
		&"max_hp_bonus", 20.0)

	_add_node(SkillNode.Track.ALIEN, &"alien_quick_reload",
		"Quick Reload",    "-10% weapon cooldown.",
		&"cooldown_multiplier", 0.9,
		[&"alien_sharp_claws"])

	_add_node(SkillNode.Track.ALIEN, &"alien_hunters_eye",
		"Hunter's Eye",    "+15% projectile range.",
		&"range_multiplier", 1.15,
		[&"alien_battle_hardened"])

	# ---- Car skills ----
	_add_node(SkillNode.Track.CAR, &"car_tuned_engine",
		"Tuned Engine",       "+10% top speed.",
		&"speed_multiplier", 1.1)

	_add_node(SkillNode.Track.CAR, &"car_reinforced_frame",
		"Reinforced Frame",   "+25 car max HP.",
		&"car_max_hp_bonus", 25.0)

	_add_node(SkillNode.Track.CAR, &"car_slick_tires",
		"Slick Tires",        "Improved drift control.",
		&"drift_multiplier", 1.1,
		[&"car_tuned_engine"])

	_add_node(SkillNode.Track.CAR, &"car_nitro_boost",
		"Nitro Boost",        "+5% recoil knockback.",
		&"knockback_multiplier", 1.05,
		[&"car_reinforced_frame"])


# ------------------------------------------------------------------ skill application

## Apply all unlocked skill effects to the car at the start of a level.
## Must be called after the car and weapon_dock are in the scene tree
## (i.e., from Level._ready() after LevelContext.level is set).
##
## Effects applied:
##   car_max_hp_bonus / max_hp_bonus → car.max_health += value
##   speed_multiplier               → all weapon_vars[i].motor_strength *= value
##   drift_multiplier               → all weapon_vars[i].drift_friction_strength *= value
##   knockback_multiplier           → all weapon_vars[i].perpendicular_multiplier *= value
##                                     and .parallel_multiplier *= value
##   cooldown_multiplier            → each weapon's ProjectileSpawnerComponent.fire_delay *= value
##   weapon_damage_multiplier       → cached in player_damage_multiplier; applied per projectile
##   range_multiplier               → cached in player_range_multiplier; applied per projectile
func apply_skills_to_car(car: Car) -> void:
	var hp_bonus:      float = 0.0
	var speed_mult:    float = 1.0
	var drift_mult:    float = 1.0
	var knockback_mult: float = 1.0
	var cooldown_mult: float = 1.0
	var damage_mult:   float = 1.0
	var range_mult:    float = 1.0

	for node: SkillNode in skill_nodes:
		if not SaveManager.is_node_unlocked(node.id):
			continue
		match node.effect_key:
			&"car_max_hp_bonus", &"max_hp_bonus":
				hp_bonus += node.effect_value
			&"speed_multiplier":
				speed_mult *= node.effect_value
			&"drift_multiplier":
				drift_mult *= node.effect_value
			&"knockback_multiplier":
				knockback_mult *= node.effect_value
			&"cooldown_multiplier":
				cooldown_mult *= node.effect_value
			&"weapon_damage_multiplier":
				damage_mult *= node.effect_value
			&"range_multiplier":
				range_mult *= node.effect_value

	# Cache projectile multipliers so player weapon lambdas can read them.
	player_damage_multiplier = damage_mult
	player_range_multiplier  = range_mult

	# HP bonus
	if hp_bonus != 0.0:
		car.max_health += hp_bonus
		car.health = car.max_health
		if is_instance_valid(LevelContext.level):
			LevelContext.level.overlay.set_hp(car.health)

	# Physics multipliers — applied to all weapon_vars SubResources so they
	# survive weapon switching (set_car_vars() reads from weapon_vars[idx]).
	# Duplicate each entry before mutating so the shared originals are not
	# permanently modified across runs.
	for i in range(car.weapon_vars.size()):
		var duped: CarVars = car.weapon_vars[i].duplicate()
		duped.motor_strength          *= speed_mult
		duped.drift_friction_strength *= drift_mult
		duped.perpendicular_multiplier *= knockback_mult
		duped.parallel_multiplier      *= knockback_mult
		car.weapon_vars[i] = duped

	# Re-apply current weapon's vars so the multipliers take effect immediately.
	var dock: WeaponDock = car.weapon_dock
	if is_instance_valid(dock):
		car.set_car_vars(car.weapon_vars[dock.current_idx])

	# Cooldown multiplier — modify fire_delay on each weapon's spawner component.
	if is_instance_valid(dock) and cooldown_mult != 1.0:
		var weapon_list: Node = dock.get_node_or_null("WeaponList")
		if weapon_list != null:
			for weapon: Node in weapon_list.get_children():
				if weapon is Weapon:
					var spawner: Node = weapon.get_node_or_null("ProjectileSpawnerComponent")
					if spawner is ProjectileSpawnerComponent:
						spawner.fire_delay *= cooldown_mult


func _add_node(
		track: SkillNode.Track,
		id: StringName,
		display_name: String,
		description: String,
		effect_key: StringName,
		effect_value: float,
		prerequisites: Array[StringName] = []) -> void:
	var n           := SkillNode.new()
	n.track         = track
	n.id            = id
	n.display_name  = display_name
	n.description   = description
	n.effect_key    = effect_key
	n.effect_value  = effect_value
	n.prerequisites = prerequisites
	n.cost          = 1
	skill_nodes.append(n)
