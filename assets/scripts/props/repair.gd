class_name Repair extends Prop

@export var repair_warea: Area2D
@onready var sprite := $Sprite2D
@onready var hit_box := $HitBoxComponent
@onready var particles: GPUParticles2D = $GPUParticles2D

func _ready():
    hit_box.has_dealt_damage.connect(_on_collision.call_deferred)
    $AnimationPlayer.play("expand")

func _on_collision(_damage: float) -> void:
    hit_box.monitoring = false
    sprite.visible = false
    particles.emitting = true
    $repair.play()
    particles.finished.connect(queue_free)