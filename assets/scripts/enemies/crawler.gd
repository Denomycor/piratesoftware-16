class_name Crawler extends Enemy

@export var health: float = 10
@export var attack_range: float = 310

@onready var gpu_particles: GPUParticles2D = $GPUParticles2D
@onready var animations: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hit_box: HitBoxComponent = $HitBoxComponent
@onready var attack_timer: Timer = $AttackCooldown

var dead := false
var can_attack := true

func _ready() -> void:
	hit_box.monitoring = false
	hurt_box.has_taken_damage.connect(_take_dmg)
	animations.frame = randi() % animations.sprite_frames.get_frame_count(animations.animation)
	animations.speed_scale = randf_range(0.8, 1.2)
	attack_timer.timeout.connect(func(): can_attack = true)
	
func attack():
	hit_box.monitoring = true
	var tween := get_tree().create_tween()
	tween.tween_callback(func(): hit_box.monitoring = false).set_delay(0.1)
	can_attack = false
	attack_timer.start()

func update_movement():
	if dead:
		return
	var distance := (target.global_position - global_position).length()
	var direction = global_position.direction_to(target.global_position)
	look_at(target.global_position)
	velocity = direction * speed
	if distance < attack_range and can_attack:
		attack()

func die():
	dead = true
	LevelContext.level.stats.increment_kills()
	LevelContext.level.stats.add_points(points)
	velocity = Vector2.ZERO
	hurt_box.has_taken_damage.disconnect(_take_dmg)
	hurt_box.queue_free()
	collision.queue_free()
	hit_box.queue_free()
	animations.visible = false
	gpu_particles.emitting = true
	gpu_particles.finished.connect(queue_free)
	died.emit()

# Signal
func _take_dmg(amount: float):
	health -= amount
	if health <= 0:
		die()
