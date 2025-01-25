class_name Bones extends Prop

@export var slow_ratio: float
@export var slow_area: Area2D

func _ready():
    slow_area.body_entered.connect(_on_collision)
    
func _on_collision(node: Node) -> void:
    if node is Car:
        node.linear_velocity = node.linear_velocity*(1-slow_ratio)
        queue_free()