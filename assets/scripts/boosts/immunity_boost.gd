## Timed boost: prevents all damage to the car for [duration] seconds.
## Implemented by disabling car.hurt_box monitoring so damage signals never fire.
class_name ImmunityBoost extends BoostPickup


func _ready() -> void:
	display_name  = "Immunity"
	display_color = Color(0.3, 0.85, 1.0, 1.0)   # cyan-blue
	duration      = 8.0
	expire_time   = 15.0
	super._ready()


func get_boost_id() -> StringName:
	return &"immunity"


func activate(car: Car) -> void:
	if is_instance_valid(car):
		car.hurt_box.monitoring = false


func deactivate(car: Car) -> void:
	if is_instance_valid(car):
		car.hurt_box.monitoring = true
