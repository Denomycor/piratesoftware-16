## Unit tests for ProgressionManager.award_run_xp().
## Uses the live SaveManager autoload, reset between tests.
extends GutTest


func before_each() -> void:
	SaveManager.reset_save()


func after_all() -> void:
	SaveManager.reset_save()


# ------------------------------------------------------------------ XP calculation

func test_award_xp_alien_is_kills_times_10() -> void:
	var result := ProgressionManager.award_run_xp(10, 0.0)
	assert_eq(result["alien_xp_gained"], 100.0,
		"10 kills * 10 XP/kill = 100 alien XP")


func test_award_xp_car_is_floor_time_over_10_times_5() -> void:
	# 100s survived: floor(100/10) * 5 = 10 * 5 = 50
	var result := ProgressionManager.award_run_xp(0, 100.0)
	assert_eq(result["car_xp_gained"], 50.0,
		"100s survived → 50 car XP")


func test_award_xp_car_floors_partial_intervals() -> void:
	# 19s: floor(19/10) = 1 → 5 XP
	var result := ProgressionManager.award_run_xp(0, 19.0)
	assert_eq(result["car_xp_gained"], 5.0)


func test_award_xp_zero_kills_zero_time() -> void:
	var result := ProgressionManager.award_run_xp(0, 0.0)
	assert_eq(result["alien_xp_gained"], 0.0)
	assert_eq(result["car_xp_gained"], 0.0)


# ------------------------------------------------------------------ level gains

func test_award_xp_reports_zero_levels_gained_when_not_enough_xp() -> void:
	var result := ProgressionManager.award_run_xp(5, 0.0)
	# 5 kills = 50 XP — not enough for level 1 (needs 100)
	assert_eq(result["alien_levels_gained"], 0)


func test_award_xp_reports_one_level_gained_at_boundary() -> void:
	# Exactly 10 kills from 0 XP → 100 alien XP → level 1
	var result := ProgressionManager.award_run_xp(10, 0.0)
	assert_eq(result["alien_levels_gained"], 1)


func test_award_xp_reports_correct_new_level() -> void:
	var result := ProgressionManager.award_run_xp(10, 0.0)
	assert_eq(result["alien_level"], 1)


func test_award_xp_cumulates_with_existing_xp() -> void:
	# Pre-seed 50 XP (halfway through level 0)
	SaveManager.set_alien_xp(50.0)
	SaveManager.set_alien_level(0)
	# Award 50 more → total 100 → level 1
	var result := ProgressionManager.award_run_xp(5, 0.0)
	assert_eq(result["alien_levels_gained"], 1,
		"Crossing level boundary with existing + new XP should count as 1 level gained")


# ------------------------------------------------------------------ return dict keys

func test_award_xp_result_contains_all_expected_keys() -> void:
	var result := ProgressionManager.award_run_xp(1, 10.0)
	var expected_keys := [
		"alien_xp_gained", "car_xp_gained",
		"alien_levels_gained", "car_levels_gained",
		"alien_level", "car_level",
		"alien_skill_points", "car_skill_points"
	]
	for key in expected_keys:
		assert_has(result, key, "Result dict should contain key '%s'" % key)


# ------------------------------------------------------------------ skill points awarded

func test_award_xp_grants_skill_point_on_level_up() -> void:
	# 10 kills from 0 → level 1 → 1 alien skill point awarded
	ProgressionManager.award_run_xp(10, 0.0)
	assert_eq(SaveManager.get_alien_skill_points(), 1)


func test_award_xp_no_skill_point_when_no_level_gained() -> void:
	ProgressionManager.award_run_xp(0, 0.0)
	assert_eq(SaveManager.get_alien_skill_points(), 0)
