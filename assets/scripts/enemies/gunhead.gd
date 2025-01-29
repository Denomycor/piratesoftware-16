class_name GunHead extends Enemy

const PROJECTILE_SCENE: PackedScene = preload("res://assets/scenes/projectiles/gunhead_projectile.tscn")

@export var health: float = 10
@export var attack_range: float = 310
@export var prediction_time: float = 2
@export var max_accelaration: float = 100000

@onready var gpu_particles: GPUParticles2D = $GPUParticles2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var attack_timer: Timer = $AttackCooldown
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D
@onready var projectile_spawner_component: ProjectileSpawnerComponent = $ProjectileSpawnerComponent

var acceleration: Vector2

var dead := false
var is_on_cooldown := false

func _ready() -> void:
	sprite.frame_changed.connect(func():
		if sprite.frame == 15:
			projectile_spawner_component.shoot(target.global_position)
	)

	projectile_spawner_component.shoot_projectile.connect(func(from: Vector2, rot: float, _data):
		var projectile: LinearProjectile = PROJECTILE_SCENE.instantiate()
		projectile.set_properties(from, rot)
		LevelContext.level.get_node("World").add_child(projectile)
	)

	projectile_spawner_component.just_shot.connect(%shooting.play)

	animation_player.play("stoped")
	hurt_box.has_taken_damage.connect(_take_dmg)
	attack_timer.timeout.connect(func(): is_on_cooldown = false)
	
func attack():
	look_at(target.global_position)
	animation_player.play("attacking")
	is_on_cooldown = true
	attack_timer.start()

func update_movement():
	if dead:
		return
	if animation_player.current_animation == "attacking":
		look_at(target.global_position)
		velocity = Vector2.ZERO
		return
	if not is_in_range():
		set_chase_acceleration()
		look_at(global_position + velocity)
	else:
		set_mimic_acceleration()
		look_at(global_position + velocity)
	if can_attack():
		attack()
	
func _physics_process(delta: float) -> void:
	if(dead):
		return

	if(!movement_locked):
		velocity += acceleration * delta
		move_and_slide()

func die():
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

func _process(_delta):
	if dead:
		return
	if animation_player.current_animation == "attacking":
		return
	if velocity.length() > 20:
		animation_player.play("running")
	else:
		animation_player.play("stoped")

# Signal
func _take_dmg(amount: float):
	health -= amount
	if health <= 0:
		die()

func can_attack() -> bool:
	return is_in_range() and !is_on_cooldown

func is_in_range() -> bool:
	var distance := (target.global_position - global_position).length()
	return distance < attack_range

func set_chase_acceleration() -> void:
	acceleration = SeekArriveSteeringBehaviour.get_steering_force(global_position, target.global_position, velocity, speed, max_accelaration, 0)

func set_mimic_acceleration() -> void:
	acceleration = SeekArriveSteeringBehaviour.get_steering_force(global_position, global_position + target.linear_velocity.normalized() * prediction_time, velocity, target.get_speed(), max_accelaration, 0)
