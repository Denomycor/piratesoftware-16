## Unit tests for ProgressionManager.unlock_skill().
## Uses the live SaveManager autoload, reset to defaults before each test.
extends GutTest


# Helper: build a minimal SkillNode for testing
func _make_node(
		id: StringName,
		track: SkillNode.Track = SkillNode.Track.ALIEN,
		cost: int = 1,
		prerequisites: Array[StringName] = []) -> SkillNode:
	var n := SkillNode.new()
	n.id           = id
	n.track        = track
	n.cost         = cost
	n.prerequisites = prerequisites
	n.effect_key   = &"weapon_damage_multiplier"
	n.effect_value = 1.1
	return n


func before_each() -> void:
	SaveManager.reset_save()


func after_all() -> void:
	SaveManager.reset_save()


# ------------------------------------------------------------------ happy path

func test_unlock_succeeds_when_alien_has_enough_points() -> void:
	SaveManager.set_alien_skill_points(1)
	var node := _make_node(&"test_skill", SkillNode.Track.ALIEN, 1)
	var result := ProgressionManager.unlock_skill(node)
	assert_true(result, "Should return true on successful unlock")


func test_unlock_marks_node_as_unlocked_in_save() -> void:
	SaveManager.set_alien_skill_points(1)
	var node := _make_node(&"test_skill")
	ProgressionManager.unlock_skill(node)
	assert_true(SaveManager.is_node_unlocked(&"test_skill"))


func test_unlock_decrements_skill_points() -> void:
	SaveManager.set_alien_skill_points(3)
	var node := _make_node(&"test_skill", SkillNode.Track.ALIEN, 1)
	ProgressionManager.unlock_skill(node)
	assert_eq(SaveManager.get_alien_skill_points(), 2)


func test_unlock_car_node_uses_car_points() -> void:
	SaveManager.set_car_skill_points(2)
	var node := _make_node(&"test_car_skill", SkillNode.Track.CAR, 1)
	ProgressionManager.unlock_skill(node)
	assert_eq(SaveManager.get_car_skill_points(), 1)


# ------------------------------------------------------------------ guard: already unlocked

func test_unlock_already_unlocked_node_returns_false() -> void:
	SaveManager.set_alien_skill_points(5)
	var node := _make_node(&"test_skill")
	ProgressionManager.unlock_skill(node)   # first unlock
	var result := ProgressionManager.unlock_skill(node)  # second attempt
	assert_false(result, "Should return false when node is already unlocked")


func test_unlock_already_unlocked_does_not_decrement_points_again() -> void:
	SaveManager.set_alien_skill_points(5)
	var node := _make_node(&"test_skill", SkillNode.Track.ALIEN, 1)
	ProgressionManager.unlock_skill(node)
	ProgressionManager.unlock_skill(node)  # second attempt (should be ignored)
	assert_eq(SaveManager.get_alien_skill_points(), 4, "Points should only be spent once")


# ------------------------------------------------------------------ guard: insufficient points

func test_unlock_with_zero_points_returns_false() -> void:
	SaveManager.set_alien_skill_points(0)
	var node := _make_node(&"test_skill")
	assert_false(ProgressionManager.unlock_skill(node))


func test_unlock_with_insufficient_points_does_not_unlock() -> void:
	SaveManager.set_alien_skill_points(0)
	var node := _make_node(&"test_skill")
	ProgressionManager.unlock_skill(node)
	assert_false(SaveManager.is_node_unlocked(&"test_skill"))


# ------------------------------------------------------------------ guard: prerequisites

func test_unlock_without_prerequisite_returns_false() -> void:
	SaveManager.set_alien_skill_points(5)
	var node := _make_node(&"test_skill", SkillNode.Track.ALIEN, 1, [&"prereq_node"])
	assert_false(ProgressionManager.unlock_skill(node))


func test_unlock_with_met_prerequisite_returns_true() -> void:
	SaveManager.set_alien_skill_points(5)
	# Unlock the prerequisite first
	SaveManager.unlock_node(&"prereq_node")
	var node := _make_node(&"test_skill", SkillNode.Track.ALIEN, 1, [&"prereq_node"])
	assert_true(ProgressionManager.unlock_skill(node))


func test_unlock_with_partial_prerequisites_fails() -> void:
	SaveManager.set_alien_skill_points(5)
	SaveManager.unlock_node(&"prereq_a")
	# prereq_b not unlocked
	var node := _make_node(&"test_skill", SkillNode.Track.ALIEN, 1,
		[&"prereq_a", &"prereq_b"])
	assert_false(ProgressionManager.unlock_skill(node))
