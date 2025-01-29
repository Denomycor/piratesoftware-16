class_name Crawler extends Enemy

@export var health: float = 10
@export var attack_range: float = 310

@onready var gpu_particles: GPUParticles2D = $GPUParticles2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hit_box: HitBoxComponent = $HitBoxComponent
@onready var attack_timer: Timer = $AttackCooldown
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite: Sprite2D = $Sprite2D

var dead := false
var is_on_cooldown := false

func _ready() -> void:
	animation_player.play("stoped")
	hit_box.monitoring = false
	hurt_box.has_taken_damage.connect(_take_dmg)
	attack_timer.timeout.connect(func(): is_on_cooldown = false)
	
func attack():
	animation_player.play("attacking")
	is_on_cooldown = true
	attack_timer.start()

func update_movement():
	if dead:
		return
	if not is_in_range():
		var direction = global_position.direction_to(target.global_position)
		look_at(target.global_position)
		velocity = direction * speed
	else:
		look_at(target.global_position)
		velocity = Vector2(0,0)
	if can_attack():
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
		animation_player.play("crawling")
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