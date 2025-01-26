class_name Barrel extends Prop

@onready var hit_box := $HitBoxComponent
@onready var hurt_box := $HurtBoxComponent
@onready var explosion_particles: GPUParticles2D = $GPUParticles2D
@onready var sprite := $Sprite2D
@onready var collision_shape := $CollisionShape2D

@export var health := 40

func _ready():
    hurt_box.has_taken_damage.connect(_on_take_damage.call_deferred)
    hit_box.monitoring = false
    

func _on_take_damage(amount: int):
    health -= amount
    if health <= 0:
        hit_box.monitoring = true
        sprite.visible=false
        collision_shape.disabled = true
        explosion_particles.emitting = true
        var tween := get_tree().create_tween()
        tween.tween_callback(queue_free).set_delay(explosion_particles.lifetime)
