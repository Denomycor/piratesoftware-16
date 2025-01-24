class_name ArenaWalls extends Node2D

@export var walls_per_side: int = 10
@export var prop_list: Array[PackedScene]
@export var ratios: Array[int]
@export var prop_density: float


var wall: PackedScene = preload("res://assets/scenes/levels/walls/Wall.tscn")
var corner: PackedScene = preload("res://assets/scenes/levels/walls/Corner.tscn")

const AVERAGE_PROP_AREA = 90000
const NUMBER_OF_SIDES: int = 8

const WALL_LENGTH: int = 1035
const CORNER_LENGTH: int = 1025

const BORDER_SIZE = 300

var angle_increment: float = 2 * PI / NUMBER_OF_SIDES
var polygon: Array[Vector2]

func _ready() -> void:
	assert(prop_list.size() == ratios.size(), "prop_list and ratios need to have same size")
	build_arena()
	print(polygon)
	generate_props()

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
		polygon.append(corner_instance.get_node("Point").global_position)
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

func is_point_inside_polygon(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point, polygon)

func get_random_point_inside_polygon(border_space: float) -> Vector2:
	var bordered_polygon := polygon
	var out_radius := (bordered_polygon[0] - position).length()
	for idx in bordered_polygon.size():
		var dir := (bordered_polygon[idx] - position).normalized()
		var new_point := dir * (out_radius - border_space)
		bordered_polygon[idx] = new_point
	var generator:= PolygonRandomPointGenerator.new(bordered_polygon)
	return generator.get_random_point()

func get_random_prop_instance() -> Node2D:
	if prop_list.size() == 0:
		return null
	var sum := 0
	for amount in ratios:
		sum += amount
	var num := randi_range(0,sum)
	sum = 0
	var idx := 0
	while sum < num && idx < prop_list.size():
		sum += ratios[idx]
		idx += 1
	return prop_list[idx-1].instantiate()

func generate_props() -> void:
	var area := 2*(1+sqrt(2))*pow(polygon[0].distance_to(polygon[1]),2) / AVERAGE_PROP_AREA
	var prop_number: int = int(area * prop_density)
	for idx in prop_number:
		var pos := get_random_point_inside_polygon(BORDER_SIZE)
		var prop := get_random_prop_instance()
		prop.global_position = pos
		get_parent().add_child.call_deferred(prop)