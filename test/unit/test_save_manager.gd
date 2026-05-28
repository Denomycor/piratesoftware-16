## Unit tests for SaveManager's in-memory logic.
## We use the live autoload but call reset_save() in before_each so each
## test starts from a clean default state without touching the real save file.
## Note: this WILL write to user://save_data.json during the test run.
## For true isolation a future refactor could inject a path, but for now
## reset_save() is sufficient regression coverage.
extends GutTest


func before_each() -> void:
	SaveManager.reset_save()


func after_all() -> void:
	# Leave save in a clean default state after the suite
	SaveManager.reset_save()


# ------------------------------------------------------------------ default state

func test_default_alien_xp_is_zero() -> void:
	assert_eq(SaveManager.get_alien_xp(), 0.0)


func test_default_car_xp_is_zero() -> void:
	assert_eq(SaveManager.get_car_xp(), 0.0)


func test_default_alien_level_is_zero() -> void:
	assert_eq(SaveManager.get_alien_level(), 0)


func test_default_car_level_is_zero() -> void:
	assert_eq(SaveManager.get_car_level(), 0)


func test_default_alien_skill_points_is_zero() -> void:
	assert_eq(SaveManager.get_alien_skill_points(), 0)


func test_default_car_skill_points_is_zero() -> void:
	assert_eq(SaveManager.get_car_skill_points(), 0)


func test_default_unlocked_nodes_is_empty() -> void:
	assert_eq(SaveManager.get_unlocked_nodes().size(), 0)


# ------------------------------------------------------------------ setters round-trip

func test_set_and_get_alien_xp() -> void:
	SaveManager.set_alien_xp(500.0)
	assert_eq(SaveManager.get_alien_xp(), 500.0)


func test_set_and_get_car_xp() -> void:
	SaveManager.set_car_xp(1234.5)
	assert_almost_eq(SaveManager.get_car_xp(), 1234.5, 0.001)


func test_set_and_get_alien_level() -> void:
	SaveManager.set_alien_level(3)
	assert_eq(SaveManager.get_alien_level(), 3)


func test_set_and_get_alien_skill_points() -> void:
	SaveManager.set_alien_skill_points(7)
	assert_eq(SaveManager.get_alien_skill_points(), 7)


# ------------------------------------------------------------------ unlock_node / is_node_unlocked

func test_node_not_unlocked_by_default() -> void:
	assert_false(SaveManager.is_node_unlocked(&"alien_sharp_claws"))


func test_unlock_node_makes_it_unlocked() -> void:
	SaveManager.unlock_node(&"alien_sharp_claws")
	assert_true(SaveManager.is_node_unlocked(&"alien_sharp_claws"))


func test_unlock_node_does_not_affect_other_nodes() -> void:
	SaveManager.unlock_node(&"alien_sharp_claws")
	assert_false(SaveManager.is_node_unlocked(&"car_tuned_engine"))


func test_unlock_node_twice_does_not_duplicate() -> void:
	SaveManager.unlock_node(&"alien_sharp_claws")
	SaveManager.unlock_node(&"alien_sharp_claws")
	var count := 0
	for id in SaveManager.get_unlocked_nodes():
		if id == "alien_sharp_claws":
			count += 1
	assert_eq(count, 1, "Node should appear exactly once even if unlocked twice")


func test_unlock_multiple_nodes() -> void:
	SaveManager.unlock_node(&"alien_sharp_claws")
	SaveManager.unlock_node(&"car_tuned_engine")
	assert_true(SaveManager.is_node_unlocked(&"alien_sharp_claws"))
	assert_true(SaveManager.is_node_unlocked(&"car_tuned_engine"))


# ------------------------------------------------------------------ reset_save

func test_reset_clears_xp() -> void:
	SaveManager.set_alien_xp(9999.0)
	SaveManager.reset_save()
	assert_eq(SaveManager.get_alien_xp(), 0.0)


func test_reset_clears_unlocked_nodes() -> void:
	SaveManager.unlock_node(&"alien_sharp_claws")
	SaveManager.reset_save()
	assert_false(SaveManager.is_node_unlocked(&"alien_sharp_claws"))
