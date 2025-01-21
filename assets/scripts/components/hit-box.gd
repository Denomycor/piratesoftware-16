class_name HitBoxComponent extends Area2D

@export var damage_amount: int
signal has_dealt_damage

func _ready() -> void:
    self.monitoring = true
    connect("area_entered", _on_area_entered)

func deal_damage(area: Area2D) -> void:
    area.take_damage(damage_amount)
    has_dealt_damage.emit(damage_amount)


# signal
func _on_area_entered(area: Area2D) -> void:
    if area.has_method("take_damage"):
        deal_damage(area)