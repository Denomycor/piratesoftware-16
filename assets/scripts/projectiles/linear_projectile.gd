class_name LinearProjectile extends CharacterBody2D


@export var speed: float
@export var lifetime: float

@onready var hitbox_component: HitBoxComponent = $HitBoxComponent

@export var scale_curve: Curve

var timer: Tween
var scale_tween: Tween

var travel_direction: Vector2
var inherited_velocity := Vector2.ZERO

var destroy_next_frame := false
var frozen := false


func _ready() -> void:
	timer = create_tween()
	timer.tween_callback(destroy).set_delay(lifetime)

	if(scale_curve):
		scale_tween = create_tween()
		scale_tween.tween_method(func(value: float):
			scale = Vector2.ONE * scale_curve.sample(value)
		, 0.0, 1.0, lifetime)

	hitbox_component.has_dealt_damage.connect(func(_p): destroy())


func set_properties(pos: Vector2, rot: float) -> void:
	global_position = pos
	rotation = rot
	travel_direction = Vector2.from_angle(rotation)


func _physics_process(delta: float) -> void:
	if(!frozen):
		if(destroy_next_frame):
			destroy()
		else:
			var motion := travel_direction * speed + inherited_velocity
			var collision := move_and_collide(motion * delta)
			if(collision):
				_on_collision(collision)


func _on_collision(_collision: KinematicCollision2D) -> void:
	schedule_destroy()


func destroy() -> void:
	queue_free()


func schedule_destroy() -> void:
	destroy_next_frame = true
	visible = false
