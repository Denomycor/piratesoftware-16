class_name Arena extends Node2D

@export var walls_per_side: int = 10
@export var average_prop_area := 90000
@export var border_size := 300
@export var scale_offset := 0.1
@export var prop_list: Array[PackedScene]
@export var ratios: Array[int]
@export var prop_density: float
@export var debug: bool = false

@onready var debug_camera: Camera2D = $Camera2D

var wall: PackedScene = preload("res://assets/scenes/levels/walls/Wall.tscn")
var corner: PackedScene = preload("res://assets/scenes/levels/walls/Corner.tscn")

const NUMBER_OF_SIDES: int = 8
const WALL_LENGTH: int = 1035
const CORNER_LENGTH: int = 1025

var angle_increment: float = 2 * PI / NUMBER_OF_SIDES
var polygon: Array[Vector2]
var point_generator: PolygonRandomPointGenerator
var props: Array[Prop]

func _ready() -> void:
	if debug:
		debug_camera.enabled = true
		debug_camera.make_current()
	else:
		debug_camera.enabled = false

	assert(prop_list.size() == ratios.size(), "prop_list and ratios need to have same size")
	build_arena()
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
		var point_pos : Vector2 = corner_instance.get_node("Point").global_position
		polygon.append(point_pos.normalized() * (point_pos.distance_to(center) - border_size))
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

func get_random_point_inside_polygon() -> Vector2:
	if point_generator == null:
		point_generator = PolygonRandomPointGenerator.new(polygon)
	return point_generator.get_random_point()

func get_random_free_point_inside_polygon(border: float) -> Vector2:
	var pos = get_random_point_inside_polygon()
	while not can_place(border, pos):
			pos = get_random_point_inside_polygon()
	return pos

func get_random_prop_instance() -> Prop:
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
	var area := 2*(1+sqrt(2))*pow(polygon[0].distance_to(polygon[1]),2) / average_prop_area
	var prop_number: int = int(area * prop_density)
	for idx in prop_number:
		var prop := get_random_prop_instance()
		prop.global_position = get_random_free_point_inside_polygon(prop.block_radius)
		prop.destroyed.connect(func(): props.erase(prop))
		apply_random_transforms(prop)
		props.append(prop)
		get_parent().add_child.call_deferred(prop)
	
func can_place(block_radius: float, pos: Vector2) -> bool:
	if not is_point_inside_polygon(pos):
		return false
	for item in props:
		if item == null:
			continue
		if item.is_overlaping(pos, block_radius):
			return false
	return true

func apply_random_transforms(prop: Prop) -> void:
	prop.rotate(randf_range(0,PI*2))
	var r_scale = 1 + (randf_range(-scale_offset,scale_offset))
	prop.scale = Vector2(r_scale, r_scale)
