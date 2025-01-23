class_name ArenaWalls extends Node2D

@export var walls_per_side: int = 10

var wall: PackedScene = preload("res://assets/scenes/levels/walls/Wall.tscn")
var corner: PackedScene = preload("res://assets/scenes/levels/walls/Corner.tscn")


const NUMBER_OF_SIDES: int = 8

const WALL_LENGTH: int = 1035
const CORNER_LENGTH: int = 1025

var angle_increment: float = 2 * PI / NUMBER_OF_SIDES

func _ready() -> void:
	build_arena()

func build_arena() -> void:

	var radius: float = walls_per_side * WALL_LENGTH + CORNER_LENGTH * (NUMBER_OF_SIDES - 2)

	var center: Vector2 = position

	var last_position: Vector2 = to_global(center) + Vector2(radius, 0)

	var direction: Vector2 = Vector2(cos(angle_increment), sin(angle_increment)).rotated(PI / 2).normalized()

	for i in range(NUMBER_OF_SIDES):
	
		last_position = build_wall(last_position, direction)
		
		var corner_instance: Node2D = corner.instantiate()
		corner_instance.position = last_position
		corner_instance.rotation = direction.angle()
		add_child(corner_instance)

		last_position += direction * CORNER_LENGTH

		direction = direction.rotated(angle_increment).normalized()

		last_position += direction * CORNER_LENGTH

func build_wall(start_position: Vector2, direction: Vector2) -> Vector2:
	var facing_angle: float = direction.rotated(PI / 2).angle()

	for i in range(walls_per_side):
		var wall_instance: Node2D = wall.instantiate()
		wall_instance.position = start_position + direction * i * WALL_LENGTH
		wall_instance.rotation = facing_angle
		add_child(wall_instance)


	return start_position + direction * walls_per_side * WALL_LENGTH
