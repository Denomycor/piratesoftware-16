class_name Barrel extends Prop

@onready var hit_box := $HitBoxComponent
@onready var hurt_box := $HurtBoxComponent

@export var health := 40

func _ready():
    hurt_box.has_taken_damage.connect(_on_take_damage)
    hit_box.monitoring = false

func _on_take_damage(amount: int):
    health -= amount
    if health <= 0:
        hit_box.monitoring = true
        queue_free()