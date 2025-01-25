class_name Crawler extends Enemy

@export var health: float = 10

@onready var gpuParticles: GPUParticles2D = $GPUParticles2D
@onready var animations: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hit_box: HitBoxComponent = $HitBoxComponent

func _ready() -> void:
	hurt_box.has_taken_damage.connect(_take_dmg)
	animations.frame = randi() % animations.sprite_frames.get_frame_count(animations.animation)
	animations.speed_scale = randf_range(0.8, 1.2)
	
func attack():
	print("I am the pacifist")

func update_movement():
	var direction = global_position.direction_to(target.global_position)
	look_at(target.global_position)
	velocity = direction * speed

func die():
	LevelContext.level.stats.increment_kills()
	died.emit()
	velocity = Vector2.ZERO
	hurt_box.has_taken_damage.disconnect(_take_dmg)
	hurt_box.queue_free()
	collision.queue_free()
	hit_box.queue_free()
	animations.visible = false
	gpuParticles.emitting = true
	gpuParticles.finished.connect(queue_free)

# Signal
func _take_dmg(amount: float):
	health -= amount
	if health <= 0:
		die()
