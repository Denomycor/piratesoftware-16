## BoostManager — autoload singleton.
##
## Responsibilities:
##  - Receives collected BoostPickup nodes from BoostPickup._collect().
##  - Runs their timed effects and ticks down remaining duration each frame.
##  - Deactivates and frees effects when their timer expires.
##  - Manages the aura damage Area2D (parented to the Car while aura is active).
##  - Exposes points_multiplier for Stats.add_points() to read.
##  - Notifies the in-game Overlay to show / update / remove timer rows.
##  - Clears all active state when the level is torn down.
## class_name intentionally omitted: Godot 4.6.3 reports "hides an autoload
## singleton" when class_name matches the autoload name. Access via autoload name.
extends Node

## Read by Stats.add_points() to apply the 2x Points multiplier.
var points_multiplier: float = 1.0

## Area2D parented to the Car while Aura Damage is active.
var _aura_area: Area2D = null
var _aura_dps: float = 0.0

## Active effects.
## Each entry is a Dictionary: { "boost": BoostPickup, "remaining": float, "car": Car }
var _active: Array = []


func _process(delta: float) -> void:
	# Guard: if the level has been torn down, reset everything and stop processing.
	if not is_instance_valid(LevelContext.level):
		clear_all()
		return

	var car: Car = LevelContext.level.car
	var overlay: Overlay = LevelContext.level.overlay

	# Tick effects in reverse so safe removal with remove_at().
	var i: int = _active.size() - 1
	while i >= 0:
		var effect: Dictionary = _active[i]
		effect["remaining"] -= delta

		var boost: BoostPickup = effect["boost"]
		var remaining: float   = effect["remaining"]

		# Update HUD timer label.
		if is_instance_valid(overlay):
			overlay.update_boost_timer(boost.get_boost_id(), remaining, boost.duration)

		if remaining <= 0.0:
			# Effect expired — deactivate, remove from overlay, free node.
			if is_instance_valid(boost):
				boost.deactivate(car)
			_active.remove_at(i)
			if is_instance_valid(overlay):
				overlay.remove_boost_display(boost.get_boost_id())
			if is_instance_valid(boost):
				boost.queue_free()
		i -= 1

	# Aura damage: apply DPS to each enemy body inside the aura area.
	if is_instance_valid(_aura_area) and is_instance_valid(car):
		for body: Node2D in _aura_area.get_overlapping_bodies():
			if body is Enemy:
				var enemy := body as Enemy
				if not enemy.dead and is_instance_valid(enemy.hurt_box):
					enemy.hurt_box.take_damage(_aura_dps * delta)


## Called by BoostPickup._collect().  Registers a new effect or resets an
## existing one of the same type (stacking = duration reset, not doubled).
func register_active_boost(boost: BoostPickup, car: Car) -> void:
	# Check for an already-active boost of the same id.
	for i: int in range(_active.size()):
		var effect: Dictionary = _active[i]
		var existing: BoostPickup = effect["boost"]
		if is_instance_valid(existing) and existing.get_boost_id() == boost.get_boost_id():
			# Reset duration on the running instance; discard the new pickup.
			effect["remaining"] = boost.duration
			_active[i] = effect
			boost.queue_free()
			if is_instance_valid(LevelContext.level) and is_instance_valid(LevelContext.level.overlay):
				LevelContext.level.overlay.update_boost_timer(
					existing.get_boost_id(), boost.duration, boost.duration)
			return

	# New effect.
	_active.append({ "boost": boost, "remaining": boost.duration, "car": car })
	boost.activate(car)

	if is_instance_valid(LevelContext.level) and is_instance_valid(LevelContext.level.overlay):
		LevelContext.level.overlay.add_boost_display(
			boost.get_boost_id(), boost.display_name, boost.display_color, boost.duration)


## Called by AuraBoost.activate().  Creates the damage Area2D as a child of the Car.
func setup_aura(car: Car, radius: float, dps: float) -> void:
	teardown_aura()
	_aura_area = Area2D.new()
	_aura_area.collision_layer = 0
	## layer 3 (enemies, value=4) | layer 6 (crawler, value=32)
	_aura_area.collision_mask = 36
	var shape_node := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape_node.shape = circle
	_aura_area.add_child(shape_node)
	car.add_child(_aura_area)
	_aura_dps = dps


## Called by AuraBoost.deactivate().  Removes the damage Area2D from the Car.
func teardown_aura() -> void:
	if is_instance_valid(_aura_area):
		_aura_area.queue_free()
	_aura_area = null
	_aura_dps = 0.0


## Clears all active boosts without calling deactivate (used on level teardown
## where the Car and overlay are already being freed).
func clear_all() -> void:
	for effect: Dictionary in _active:
		var boost: BoostPickup = effect["boost"]
		if is_instance_valid(boost):
			boost.queue_free()
	_active.clear()
	points_multiplier = 1.0
	# _aura_area is parented to the Car, freed automatically with it.
	_aura_area = null
	_aura_dps  = 0.0
