class_name Giant extends Enemy


@export var health: float = 1000
@export var max_accelaration: float = 100000
@export var attack_range: float = 310

@export var charge_time := 3.0
@export var charge_speed := 1500
@export var charge_range := 2500
@export var charge_color: Color
var charge_is_on_cooldown := false

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hit_box: HitBoxComponent = $HitBoxComponent
@onready var gpu_particles: GPUParticles2D = $GPUParticles2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_timer: Timer = $attack_timer
@onready var charge_timer: Timer = $attack_timer

var dead := false
var attack_is_on_cooldown := false
var speed_backup: float
var acceleration: Vector2


func _ready() -> void:
	attack_timer.timeout.connect(func(): attack_is_on_cooldown = false)
	charge_timer.timeout.connect(func(): charge_is_on_cooldown = false)
	hurt_box.has_taken_damage.connect(_take_dmg)
	hit_box.monitoring = false


func update_movement():
	if dead:
		return
	if not is_in_range(attack_range):
		if(charge_is_on_cooldown || !is_in_range(charge_range)):
			set_chase_acceleration()
			look_at(global_position + velocity)
		else:
			start_charge()
	else:
		look_at(target.global_position)
		velocity = Vector2(0,0)
	if can_attack():
		attack()


func _physics_process(delta: float) -> void:
	if(dead):
		return

	if(!movement_locked):
		velocity += acceleration * delta
		move_and_slide()

func _process(_delta: float):
	if dead:
		return
	if velocity.length() > 20:
		animation_player.play("walking")
	else:
		animation_player.play("RESET")


func set_chase_acceleration() -> void:
	acceleration = SeekArriveSteeringBehaviour.get_steering_force(global_position, target.global_position, velocity, speed, max_accelaration, 0)


func die() -> void:
	dead = true
	LevelContext.level.stats.increment_kills()
	LevelContext.level.stats.add_points(points)
	velocity = Vector2.ZERO
	hurt_box.has_taken_damage.disconnect(_take_dmg)
	hurt_box.queue_free()
	collision.queue_free()
	sprite.visible = false
	gpu_particles.emitting = true
	gpu_particles.finished.connect(queue_free)
	died.emit()


# Signal
func _take_dmg(amount: float):
	health -= amount
	if health <= 0:
		die()

func is_in_range(frange: float) -> bool:
	var distance := (target.global_position - global_position).length()
	return distance < frange


func can_attack() -> bool:
	return is_in_range(attack_range) and !attack_is_on_cooldown


func attack() -> void:
	attack_is_on_cooldown = true
	animation_player.play("attacking")
	attack_timer.start()


func end_charge() -> void:
	$Sprite2D.self_modulate = Color.WHITE
	speed = speed_backup
	charge_timer.start()


func start_charge() -> void:
	charge_is_on_cooldown = true
	create_tween().tween_callback(end_charge).set_delay(charge_time)
	$Sprite2D.self_modulate = charge_color
	speed_backup = speed
	speed = charge_speed

