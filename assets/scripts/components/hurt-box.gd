class_name HurtBoxComponent extends Area2D

signal has_taken_damage

func _ready() -> void:
    self.monitoring = false

func take_damage(amount: int) -> void:
        has_taken_damage.emit(amount)