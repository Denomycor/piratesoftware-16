class_name ProjectileSpawnerComponent extends Node2D


signal shoot_projectile(from: Vector2, rot: float, data: Variant)
signal projectile_ready
signal just_shot

@export var fire_delay: float
@export var multishot: int
@export var spread: float

@export var bullet_spawn: Node2D = self

var delay_acc: float
var proj_ready := true
var enabled := true


func _ready() -> void:
	delay_acc = fire_delay


func _process(delta: float) -> void:
	if !proj_ready:
		if delay_acc < delta:
			proj_ready = true
			projectile_ready.emit()
		else:
			delay_acc -= delta


func shoot(to: Vector2, data: Variant = null) -> void:
	if (proj_ready or fire_delay <= 0.0) and enabled:
		for i in range(multishot):
			var angle: float = (to - global_position).angle() + (randf() - 0.5) * spread
			shoot_projectile.emit(bullet_spawn.global_position, angle, data)
		proj_ready = false
		delay_acc = fire_delay
		just_shot.emit()

