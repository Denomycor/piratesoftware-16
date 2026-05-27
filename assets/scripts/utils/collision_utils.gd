class_name CollisionUtils

## Returns the collision damage amount given speed and tuning parameters.
## Linearly interpolates damage from 0 to max_damage based on how much
## collision_speed exceeds min_speed, clamped to [0, max_damage].
static func calculate_damage(
    collision_speed: float,
    min_speed: float,
    max_speed: float,
    max_damage: float
) -> float:
    return clampf(
        lerpf(0.0, max_damage, (collision_speed - min_speed) / (max_speed - min_speed)),
        0.0,
        max_damage
    )
