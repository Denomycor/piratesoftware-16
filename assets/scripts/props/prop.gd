class_name Prop extends CollisionObject2D

@export var block_radius: float

signal destroyed

func is_overlaping(pos: Vector2, block_rad: float) -> bool:
    var dir := pos.direction_to(global_position)
    return Geometry2D.segment_intersects_circle(pos, pos + dir*block_rad, global_position, block_rad) != -1

func destroy():
    destroyed.emit()
    queue_free()
