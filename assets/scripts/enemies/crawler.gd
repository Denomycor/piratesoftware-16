class_name Crawler extends Enemy

@export var attack_range: float = 310
@export var speed_for_kill: float = 600

@onready var gpu_particles: GPUParticles2D = $GPUParticles2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hit_box: HitBoxComponent = $HitBoxComponent
@onready var attack_timer: Timer = $AttackCooldown
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var is_on_cooldown := false

func _ready() -> void:
	super()
	hurt_box.monitoring = true
	hurt_box.body_entered.connect(_on_collision)
	sprite.frame = randi() % 5
	hit_box.monitoring = false
	attack_timer.timeout.connect(func(): is_on_cooldown = false)

func attack() -> void:
	%growl.pitch_scale = randf_range(0.7, 1.4)
	%growl.play()
	animation_player.play("attacking")
	is_on_cooldown = true
	attack_timer.start()

func update_movement() -> void:
	if dead:
		return
	if not is_in_range():
		set_chase_acceleration()
		look_at(global_position + velocity)
	else:
		look_at(target.global_position)
		velocity = Vector2.ZERO
	if can_attack():
		attack()

func _on_die() -> void:
	%squish.play()
	collision.queue_free()
	hit_box.queue_free()
	sprite.visible = false
	gpu_particles.emitting = true
	gpu_particles.finished.connect(queue_free)

func _physics_process(delta: float) -> void:
	if dead:
		return

	if !movement_locked:
		velocity += acceleration * delta
		move_and_slide()

func _process(_delta: float) -> void:
	if dead:
		return
	if animation_player.current_animation == "attacking":
		return
	if velocity.length() > 20:
		animation_player.play("crawling")
	else:
		animation_player.play("stopped")

func can_attack() -> bool:
	return is_in_range() and !is_on_cooldown

func is_in_range() -> bool:
	return get_distance_to_target() < attack_range

func _on_collision(node: Node) -> void:
	if not node is Car:
		return
	var collision_direction: Vector2 = node.global_position.direction_to(global_position)
	var collision_speed: float = node.last_velocity.dot(collision_direction)
	var collision_damage := lerpf(0, health, collision_speed / speed_for_kill)
	if not dead:
		_take_dmg(collision_damage)
