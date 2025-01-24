class_name Crawler extends Enemy

@export var health: int = 10

@onready var gpuParticles: GPUParticles2D = $GPUParticles2D
@onready var animations: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	hurt_box.has_taken_damage.connect(_take_dmg)


func attack():
	print("I am the pacifist")

func update_movement():
	var direction = global_position.direction_to(target.global_position)
	look_at(target.global_position)
	velocity = direction * speed

func die():
	died.emit()
	animations.visible = false
	gpuParticles.emitting = true
	gpuParticles.finished.connect(queue_free)

# Signal
func _take_dmg(amount: int):
	health -= amount
	if health <= 0:
		die()
