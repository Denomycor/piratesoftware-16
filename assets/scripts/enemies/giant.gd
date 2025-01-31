class_name Giant extends Enemy

const PROJ_SCENE := preload("res://assets/scenes/projectiles/goo_projectile.tscn")

@export var health: float = 1000
@export var max_accelaration: float = 100000
@export var melee_attack_range: float = 310

@export var charge_time := 3.0
@export var charge_speed := 1500
@export var charge_range := 2500
@export var charge_color: Color
var charge_is_on_cooldown := true

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hit_box: HitBoxComponent = $HitBoxComponent
@onready var gpu_particles: GPUParticles2D = $GPUParticles2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var attack_timer: Timer = $attack_timer
@onready var charge_timer: Timer = $attack_timer
@onready var projectile_spawner_component: ProjectileSpawnerComponent = $ProjectileSpawnerComponent

@export var ranged_attack_range := 2000


var dead := false
var attack_is_on_cooldown := false
var speed_backup: float
var acceleration: Vector2


func _ready() -> void:
	attack_timer.timeout.connect(func(): attack_is_on_cooldown = false)
	charge_timer.timeout.connect(func(): charge_is_on_cooldown = false)
	hurt_box.has_taken_damage.connect(_take_dmg)
	hit_box.monitoring = false

	projectile_spawner_component.shoot_projectile.connect(func(from: Vector2, rot: float, _data):
		var projectile: GooProjectile = PROJ_SCENE.instantiate()
		projectile.set_properties(from, rot)
		LevelContext.level.get_node("World").add_child(projectile)
	)


func update_movement():
	if dead:
		return
	if can_attack_melee() && animation_player.current_animation != "firing":
		look_at(target.global_position)
		velocity = Vector2(0,0)
		attack_melee()
	elif can_attack_ranged() && animation_player.current_animation != "attacking2" :
		look_at(target.global_position)
		velocity = Vector2(0,0)
		attack_ranged()
	elif(animation_player.current_animation != "firing" && animation_player.current_animation != "attacking2"):
		move()


func move() -> void:
	if(charge_is_on_cooldown || !is_in_range(charge_range)):
		set_chase_acceleration()
		look_at(global_position + velocity)
	else:
		start_charge()


func _physics_process(delta: float) -> void:
	if(!dead):
		if(!movement_locked):
			velocity += acceleration * delta
			move_and_slide()


func _process(_delta: float):
	if dead:
		return
	if animation_player.current_animation == "attacking2" || animation_player.current_animation == "firing":
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


func can_attack_melee() -> bool:
	return is_in_range(melee_attack_range) && !attack_is_on_cooldown


func can_attack_ranged() -> bool:
	return is_in_range(ranged_attack_range) && projectile_spawner_component.proj_ready


func attack_melee() -> void:
	attack_is_on_cooldown = true
	animation_player.play("attacking2")
	attack_timer.start()


func attack_ranged() -> void:
	animation_player.play("firing")


func _animation_synced_shot() -> void:
	# Ensure proj shoots
	projectile_spawner_component.proj_ready = true
	projectile_spawner_component.shoot(target.global_position)


func end_charge() -> void:
	$Sprite2D.self_modulate = Color.WHITE
	animation_player.speed_scale = 0.6
	speed = speed_backup
	charge_timer.start()


func start_charge() -> void:
	charge_is_on_cooldown = true
	create_tween().tween_callback(end_charge).set_delay(charge_time)
	$Sprite2D.self_modulate = charge_color
	animation_player.speed_scale = 1
	speed_backup = speed
	speed = charge_speed


func play_cracks() -> void:
	$Node/crack.global_position = $HitBoxComponent/CollisionShape2D.global_position
	$Node/AnimationPlayer.play("crack_start")
	create_tween().tween_callback($Node/AnimationPlayer.play.bind("crack_end")).set_delay(3)

