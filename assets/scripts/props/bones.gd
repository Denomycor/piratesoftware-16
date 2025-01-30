class_name Bones extends Prop

@export var slow_ratio: float
@export var slow_area: Area2D
@export var sprites: Array[Sprite2D]
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var particles: GPUParticles2D = $GPUParticles2D

func _ready():
    slow_area.body_entered.connect(_on_collision.call_deferred)
    
func _on_collision(node: Node) -> void:
    if node is Car:
        node.linear_velocity = node.linear_velocity*(1-slow_ratio)
        for sprite in sprites:
            sprite.visible = false
        particles.emitting = true
        $break.play()
        collision_shape.disabled = true
        particles.finished.connect(queue_free)