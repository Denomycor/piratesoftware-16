## Unit tests for SeekArriveSteeringBehaviour (pure static math).
## No scene tree or autoloads required.
extends GutTest


# ------------------------------------------------------------------ get_desired_velocity

func test_desired_velocity_points_toward_target() -> void:
	var from   := Vector2(0, 0)
	var target := Vector2(100, 0)
	var vel    := SeekArriveSteeringBehaviour.get_desired_velocity(from, target, 200.0, 50.0)
	# Should point in the +X direction
	assert_gt(vel.x, 0.0, "desired velocity X should be positive (toward target)")
	assert_almost_eq(vel.y, 0.0, 0.001, "desired velocity Y should be ~0 (straight line)")


func test_desired_velocity_magnitude_capped_at_max_speed_when_far() -> void:
	var from   := Vector2(0, 0)
	var target := Vector2(10000, 0)  # very far
	var max_speed := 300.0
	var vel := SeekArriveSteeringBehaviour.get_desired_velocity(from, target, max_speed, 50.0)
	assert_almost_eq(vel.length(), max_speed, 0.01,
		"Speed should equal max_speed when far from target")


func test_desired_velocity_slows_inside_arrival_distance() -> void:
	# Place agent just inside the arrival radius
	var from   := Vector2(0, 0)
	var target := Vector2(20, 0)  # distance = 20, arrival_distance = 50 → inside
	var vel := SeekArriveSteeringBehaviour.get_desired_velocity(from, target, 200.0, 50.0)
	# Speed must be less than max_speed
	assert_lt(vel.length(), 200.0, "Speed should slow down inside arrival distance")


func test_desired_velocity_at_target_is_zero() -> void:
	var pos := Vector2(50, 50)
	var vel := SeekArriveSteeringBehaviour.get_desired_velocity(pos, pos, 200.0, 10.0)
	assert_almost_eq(vel.length(), 0.0, 0.001,
		"Desired velocity should be ~0 when already at target")


# ------------------------------------------------------------------ get_steering_force

func test_steering_force_points_toward_target_when_stationary() -> void:
	var from    := Vector2(0, 0)
	var target  := Vector2(500, 0)
	var current_vel := Vector2(0, 0)
	var force := SeekArriveSteeringBehaviour.get_steering_force(
		from, target, current_vel, 200.0, 500.0, 50.0)
	assert_gt(force.x, 0.0, "Steering force X should be positive (toward target)")
	assert_almost_eq(force.y, 0.0, 0.001)


func test_steering_force_is_zero_when_already_moving_correctly_at_target() -> void:
	# Agent at target, velocity already 0 → no force needed
	var pos := Vector2(100, 100)
	var force := SeekArriveSteeringBehaviour.get_steering_force(
		pos, pos, Vector2.ZERO, 200.0, 500.0, 10.0)
	assert_almost_eq(force.length(), 0.0, 0.001,
		"Force should be ~0 when at target with zero velocity")


func test_steering_force_capped_at_max_steering_force() -> void:
	var from   := Vector2(0, 0)
	var target := Vector2(10000, 0)
	var max_force := 100.0
	var force := SeekArriveSteeringBehaviour.get_steering_force(
		from, target, Vector2.ZERO, 500.0, max_force, 50.0)
	assert_lte(force.length(), max_force + 0.001,
		"Steering force magnitude must not exceed max_steering_force")
