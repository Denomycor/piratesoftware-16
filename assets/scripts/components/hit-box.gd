class_name HitBoxComponent extends Area2D

@export var damage_amount: float
@export var one_shot := false

var one_shot_available := true

signal has_dealt_damage(damage: int)

func _ready() -> void:
    self.monitoring = true
    self.monitorable = false
    area_entered.connect(_on_area_entered)

func deal_damage(area: Area2D) -> void:
    area.take_damage(damage_amount)
    has_dealt_damage.emit(damage_amount)


# signal
func _on_area_entered(area: Area2D) -> void:
    if area.has_method("take_damage") && one_shot_available:
        one_shot_available = !(one_shot && one_shot_available)
        deal_damage(area)

