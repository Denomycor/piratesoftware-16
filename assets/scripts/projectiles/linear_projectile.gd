class_name LinearProjectile extends CharacterBody2D


@export var speed: float
@export var lifetime: float

@onready var hitbox_component: HitBoxComponent = $HitBoxComponent

var timer: Tween
var travel_direction: Vector2
var inherited_velocity := Vector2.ZERO

var destroy_next_frame := false


func _ready() -> void:
	timer = create_tween()
	timer.tween_callback(destroy).set_delay(lifetime)
	hitbox_component.has_dealt_damage.connect(destroy)


func set_properties(pos: Vector2, rot: float) -> void:
	global_position = pos
	rotation = rot
	travel_direction = Vector2.from_angle(rotation)


func _physics_process(_delta: float) -> void:
	if(destroy_next_frame):
		destroy()
	else:
		var motion := (travel_direction * speed) + inherited_velocity
		var collision := move_and_collide(motion)
		if(collision):
			schedule_destroy()


func destroy() -> void:
	queue_free()


func schedule_destroy() -> void:
	destroy_next_frame = true
	visible = false

