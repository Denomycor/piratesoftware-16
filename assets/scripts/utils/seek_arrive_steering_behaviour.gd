class_name SeekArriveSteeringBehaviour extends RefCounted

static func get_steering_force(current_position: Vector2, target_position: Vector2, current_velocity: Vector2, max_speed: float, max_steering_force: float, arrival_distance: float) -> Vector2:
	var desired_velocity := get_desired_velocity(current_position, target_position, max_speed, arrival_distance)
	var force_length := clampf((desired_velocity-current_velocity).length(),0,max_steering_force)
	return (desired_velocity-current_velocity).normalized() * force_length

static func get_desired_velocity(current_position: Vector2, target_position: Vector2, max_speed: float, arrival_distance: float) -> Vector2:
	var distance_from_target := (target_position-current_position).length()
	var desired_speed := max_speed
	desired_speed = clampf(lerp(max_speed, 0.0, (arrival_distance-distance_from_target)/arrival_distance),0,max_speed)
	return (target_position-current_position).normalized()*desired_speed
