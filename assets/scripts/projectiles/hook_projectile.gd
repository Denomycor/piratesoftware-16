class_name HookProjectile extends CharacterBody2D

@export var speed: float
@export var lifetime: float
@export var drag_dist: float = 900

@onready var area_collision: Area2D = $Area2D
@onready var cable: Line2D = $Line2D


var target: PhysicsBody2D
var car: RigidBody2D
var timer: Tween
var inherited_velocity := Vector2.ZERO

var hit_target: bool = false


func _ready() -> void:
	area_collision.area_entered.connect(_on_area_entered)
	car = LevelContext.level.get_node("World").get_node("Car")
	timer = create_tween()
	timer.tween_callback(destroy).set_delay(lifetime)


func set_properties(pos: Vector2, rot: float) -> void:
	global_position = pos
	rotation = rot


func _physics_process(delta: float) -> void:
	cable.points[0] = cable.to_local(car.global_position)
	cable.points[1] = cable.to_local(global_position)

	if hit_target:
		handle_has_target()
	else:
		var motion := Vector2.from_angle(rotation) * speed
		move_and_collide(motion + inherited_velocity * delta)


func destroy() -> void:
	queue_free()


func handle_has_target() -> void:
	var cur_dist: float = car.global_position.distance_to(target.global_position)
	var new_dist: float = move_toward(cur_dist, drag_dist, 300)
	
	var dir: Vector2 = car.global_position.direction_to(target.global_position)
	var new_pos: Vector2 = car.global_position + dir * new_dist
	target.global_position = new_pos
	global_position = new_pos


func _on_area_entered(area: Area2D) -> void:
	target = area.get_parent()
	hit_target = true
	timer.kill()
	if(area.get_parent() is Enemy):
		(area.get_parent() as Enemy).died.connect(destroy)

	area_collision.area_entered.disconnect(_on_area_entered)
