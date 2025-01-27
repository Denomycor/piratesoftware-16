class_name ProjectileSpawnerComponent extends Node2D


signal shoot_projectile(from: Vector2, rot: float, data: Variant)
signal projectile_ready
signal burst_ready
signal just_shot

@export var fire_delay: float
@export var multishot: int
@export var spread: float

@export var burst_delay: float
@export var burst_amount: float

@export var bullet_spawn: Node2D = self

var burst_count := 0

var delay_acc: float
var burst_delay_acc: float
var proj_ready := true
var bst_ready := true
var enabled := true


func _ready() -> void:
	delay_acc = fire_delay
	burst_delay_acc = burst_delay


func _process(delta: float) -> void:
	if !proj_ready:
		delay_acc -= delta
		if delay_acc < delta:
			proj_ready = true
			projectile_ready.emit()

	if !bst_ready:
		burst_delay_acc -= delta
		if burst_delay_acc < delta:
			bst_ready = true
			burst_ready.emit()


func shoot(to: Vector2, data: Variant = null) -> void:
	if proj_ready and bst_ready and enabled:
		for i in range(multishot):
			var angle: float = (to - global_position).angle() + (randf() - 0.5) * spread
			shoot_projectile.emit(bullet_spawn.global_position, angle, data)
			burst_count += 1
		proj_ready = false
		delay_acc = fire_delay
		if burst_count >= burst_amount:
			bst_ready = false
			burst_count = 0
			burst_delay_acc = burst_delay
		just_shot.emit()

