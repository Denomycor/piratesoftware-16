## Unit tests for HurtBoxComponent signal behaviour.
## HurtBoxComponent has no external dependencies — pure signal relay.
extends GutTest


var _hb: HurtBoxComponent


func before_each() -> void:
	_hb = HurtBoxComponent.new()
	add_child_autofree(_hb)
	watch_signals(_hb)


# ------------------------------------------------------------------ take_damage

func test_take_damage_emits_has_taken_damage() -> void:
	_hb.take_damage(10.0)
	assert_signal_emitted(_hb, "has_taken_damage")


func test_take_damage_passes_correct_amount() -> void:
	_hb.take_damage(25.0)
	assert_signal_emitted_with_parameters(_hb, "has_taken_damage", [25.0])


func test_take_damage_zero_still_emits() -> void:
	_hb.take_damage(0.0)
	assert_signal_emitted(_hb, "has_taken_damage")


func test_take_damage_called_twice_emits_twice() -> void:
	_hb.take_damage(10.0)
	_hb.take_damage(20.0)
	assert_signal_emit_count(_hb, "has_taken_damage", 2)


func test_take_damage_second_call_uses_correct_amount() -> void:
	_hb.take_damage(5.0)
	_hb.take_damage(99.0)
	# Most recent call should have passed 99.0
	assert_signal_emitted_with_parameters(_hb, "has_taken_damage", [99.0])
