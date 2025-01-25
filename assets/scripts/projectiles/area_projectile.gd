class_name AreaProjectile extends CharacterBody2D

@export var speed: float
@export var reach: float

@onready var hitbox_component : HitBoxComponent = $HitBoxComponent
@onready var area_hitbox_component : HitBoxComponent = $AreaHitBoxComponent

var reach_acc := 0.0

func _ready() -> void:
	hitbox_component.has_dealt_damage.connect(_activate_area)
	area_hitbox_component.monitoring = false


func set_properties(pos: Vector2, rot: float) -> void:
	global_position = pos
	rotation = rot


func _physics_process(_delta) -> void:
	var motion := Vector2.from_angle(rotation) * speed
	if (reach_acc < reach):
		reach_acc += motion.length()
		move_and_collide(motion)
	else:
		destroy()


func destroy() -> void:
	queue_free()


func _activate_area(_damage: int):
	area_hitbox_component.monitoring = true
