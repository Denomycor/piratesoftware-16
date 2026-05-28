## Unit tests for the abstract Weapon base class.
## Tests state toggling (active flag) and signal emission.
extends GutTest


var _weapon: Weapon


func before_each() -> void:
	_weapon = Weapon.new()
	add_child_autofree(_weapon)
	watch_signals(_weapon)


# ------------------------------------------------------------------ initial state

func test_weapon_starts_inactive() -> void:
	assert_false(_weapon.active, "Weapon should start inactive")


# ------------------------------------------------------------------ activate

func test_activate_sets_active_true() -> void:
	_weapon.activate()
	assert_true(_weapon.active)


func test_activate_emits_activated_signal() -> void:
	_weapon.activate()
	assert_signal_emitted(_weapon, "activated")


func test_activate_emits_exactly_once() -> void:
	_weapon.activate()
	assert_signal_emit_count(_weapon, "activated", 1)


func test_activate_twice_emits_activated_twice() -> void:
	_weapon.activate()
	_weapon.activate()
	assert_signal_emit_count(_weapon, "activated", 2)


func test_activate_does_not_emit_deactivated() -> void:
	_weapon.activate()
	assert_signal_not_emitted(_weapon, "deactivated")


# ------------------------------------------------------------------ deactivate

func test_deactivate_sets_active_false() -> void:
	_weapon.activate()
	_weapon.deactivate()
	assert_false(_weapon.active)


func test_deactivate_emits_deactivated_signal() -> void:
	_weapon.activate()
	_weapon.deactivate()
	assert_signal_emitted(_weapon, "deactivated")


func test_deactivate_emits_exactly_once() -> void:
	_weapon.activate()
	_weapon.deactivate()
	assert_signal_emit_count(_weapon, "deactivated", 1)


func test_deactivate_without_activate_still_sets_active_false() -> void:
	_weapon.deactivate()
	assert_false(_weapon.active)


# ------------------------------------------------------------------ activate/deactivate cycle

func test_activate_deactivate_cycle_leaves_inactive() -> void:
	_weapon.activate()
	_weapon.deactivate()
	assert_false(_weapon.active)


func test_multiple_cycles_emit_correct_counts() -> void:
	_weapon.activate()
	_weapon.deactivate()
	_weapon.activate()
	_weapon.deactivate()
	assert_signal_emit_count(_weapon, "activated", 2)
	assert_signal_emit_count(_weapon, "deactivated", 2)
