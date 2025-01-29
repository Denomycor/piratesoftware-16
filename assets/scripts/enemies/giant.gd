class_name Giant extends Enemy


@export var health: float = 1000
@export var max_accelaration: float = 100000
@export var attack_range: float = 310

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var gpu_particles: GPUParticles2D = $GPUParticles2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var dead := false
var is_on_cooldown := false

var acceleration: Vector2


func _ready() -> void:
	hurt_box.has_taken_damage.connect(_take_dmg)


func update_movement():
	if dead:
		return
	if not is_in_range():
		set_chase_acceleration()
		look_at(global_position + velocity)
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

func is_in_range() -> bool:
	var distance := (target.global_position - global_position).length()
	return distance < attack_range


func can_attack() -> bool:
	return is_in_range() and !is_on_cooldown

