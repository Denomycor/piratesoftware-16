## Unit tests for ProgressionManager XP math (static functions only).
## No autoloads, no scene tree — pure arithmetic regression tests.
extends GutTest


# ------------------------------------------------------------------ xp_for_next_level

func test_xp_for_level_0_costs_100() -> void:
	assert_eq(ProgressionManager.xp_for_next_level(0), 100.0)


func test_xp_for_level_1_costs_200() -> void:
	assert_eq(ProgressionManager.xp_for_next_level(1), 200.0)


func test_xp_for_level_9_costs_1000() -> void:
	assert_eq(ProgressionManager.xp_for_next_level(9), 1000.0)


func test_xp_for_next_level_scales_linearly() -> void:
	# Cost(N) = (N+1) * 100
	for n in range(5):
		assert_eq(ProgressionManager.xp_for_next_level(n), float((n + 1) * 100),
			"xp_for_next_level(%d) should be %d" % [n, (n + 1) * 100])


# ------------------------------------------------------------------ level_from_xp

func test_level_from_xp_zero_is_0() -> void:
	assert_eq(ProgressionManager.level_from_xp(0.0), 0)


func test_level_from_xp_99_is_0() -> void:
	# Not enough to complete level 0→1 (needs 100)
	assert_eq(ProgressionManager.level_from_xp(99.9), 0)


func test_level_from_xp_100_is_1() -> void:
	assert_eq(ProgressionManager.level_from_xp(100.0), 1)


func test_level_from_xp_299_is_1() -> void:
	# 100 (level 0→1) + 199 (not enough for level 1→2 which needs 200)
	assert_eq(ProgressionManager.level_from_xp(299.0), 1)


func test_level_from_xp_300_is_2() -> void:
	# 100 (0→1) + 200 (1→2) = 300 total
	assert_eq(ProgressionManager.level_from_xp(300.0), 2)


func test_level_from_xp_600_is_3() -> void:
	# 100 + 200 + 300 = 600
	assert_eq(ProgressionManager.level_from_xp(600.0), 3)


func test_level_from_xp_large_value_is_consistent_with_xp_for_next_level() -> void:
	# Walk up 10 levels and verify level_from_xp matches
	var total_xp: float = 0.0
	for lvl in range(10):
		total_xp += ProgressionManager.xp_for_next_level(lvl)
		assert_eq(ProgressionManager.level_from_xp(total_xp), lvl + 1,
			"After accumulating XP through level %d, level should be %d" % [lvl, lvl + 1])


# ------------------------------------------------------------------ xp_on_current_level

func test_xp_on_current_level_at_zero_xp() -> void:
	assert_eq(ProgressionManager.xp_on_current_level(0.0), 0.0)


func test_xp_on_current_level_50_xp_into_level_0() -> void:
	assert_eq(ProgressionManager.xp_on_current_level(50.0), 50.0)


func test_xp_on_current_level_after_first_levelup() -> void:
	# 150 XP: 100 consumed by 0→1, 50 remaining into level 1
	assert_eq(ProgressionManager.xp_on_current_level(150.0), 50.0)


func test_xp_on_current_level_exactly_at_boundary_is_zero() -> void:
	# 300 XP: levels 0→1 (100) + 1→2 (200) = exactly at level 2 start
	assert_eq(ProgressionManager.xp_on_current_level(300.0), 0.0)


func test_xp_on_current_level_is_always_less_than_xp_for_next_level() -> void:
	# For any XP value, remainder must be < cost to advance from current level
	var test_values: Array = [0.0, 50.0, 100.0, 250.0, 600.0, 1234.0, 5000.0]
	for xp: float in test_values:
		var level := ProgressionManager.level_from_xp(xp)
		var remainder := ProgressionManager.xp_on_current_level(xp)
		var cost := ProgressionManager.xp_for_next_level(level)
		assert_lt(remainder, cost,
			"xp_on_current_level(%s) = %s should be < xp_for_next_level(%d) = %s" % [xp, remainder, level, cost])
