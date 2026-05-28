## Integration tests for the HitBoxComponent → HurtBoxComponent damage pipeline.
## Tests that deal_damage() routes through take_damage() and fires signals correctly.
extends GutTest


var _hit_box: HitBoxComponent
var _hurt_box: HurtBoxComponent


func before_each() -> void:
	_hit_box = HitBoxComponent.new()
	_hit_box.damage_amount = 20.0

	_hurt_box = HurtBoxComponent.new()

	add_child_autofree(_hit_box)
	add_child_autofree(_hurt_box)
	watch_signals(_hit_box)
	watch_signals(_hurt_box)


# ------------------------------------------------------------------ deal_damage direct call

func test_deal_damage_calls_take_damage_and_emits_has_taken_damage() -> void:
	_hit_box.deal_damage(_hurt_box)
	assert_signal_emitted(_hurt_box, "has_taken_damage")


func test_deal_damage_passes_correct_amount_to_hurt_box() -> void:
	_hit_box.damage_amount = 42.0
	_hit_box.deal_damage(_hurt_box)
	assert_signal_emitted_with_parameters(_hurt_box, "has_taken_damage", [42.0])


func test_deal_damage_emits_has_dealt_damage_on_hit_box() -> void:
	_hit_box.deal_damage(_hurt_box)
	assert_signal_emitted(_hit_box, "has_dealt_damage")


func test_deal_damage_has_dealt_damage_carries_amount() -> void:
	_hit_box.damage_amount = 15.0
	_hit_box.deal_damage(_hurt_box)
	assert_signal_emitted_with_parameters(_hit_box, "has_dealt_damage", [15.0])


# ------------------------------------------------------------------ repeated calls

func test_deal_damage_called_twice_deals_twice() -> void:
	# deal_damage() has no one_shot guard — that lives in _on_area_entered.
	# Verifies the public API always applies damage when called directly.
	_hit_box.deal_damage(_hurt_box)
	_hit_box.deal_damage(_hurt_box)
	assert_signal_emit_count(_hurt_box, "has_taken_damage", 2)


func test_one_shot_flag_starts_available() -> void:
	# The one_shot guard (one_shot_available) starts true by default
	assert_true(_hit_box.one_shot_available)
