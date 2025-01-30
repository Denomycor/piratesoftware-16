class_name Barrel extends Prop

@onready var hit_box := $HitBoxComponent
@onready var hurt_box := $HurtBoxComponent
@onready var explosion_particles: GPUParticles2D = $GPUParticles2D
@onready var sprite := $Sprite2D
@onready var collision_shape := $CollisionShape2D

@export var health := 40
@export var rigid_body : RigidBody2D

var last_velocity : Vector2

func _ready():
    hurt_box.has_taken_damage.connect(_on_take_damage.call_deferred)
    hit_box.monitoring = false
    
func _physics_process(_delta):
    last_velocity = rigid_body.linear_velocity

func _on_take_damage(amount: int):
    health -= amount
    if health <= 0:
        hit_box.monitoring = true
        hurt_box.monitorable = false
        sprite.visible=false
        collision_shape.disabled = true
        explosion_particles.emitting = true
        var tween := get_tree().create_tween()
        %explosion.pitch_scale = randf_range(1, 1.4)
        %explosion.play()
        tween.tween_callback(destroy).set_delay(explosion_particles.lifetime)

func get_last_velocity() -> Vector2:
    return last_velocity
