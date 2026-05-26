## Timed boost: doubles all point gains for [duration] seconds.
## Points multiplier is stored on BoostManager and read by Stats.add_points().
class_name TwoPointsBoost extends BoostPickup


func _ready() -> void:
	display_name  = "2x Points"
	display_color = Color(1.0, 0.85, 0.0, 1.0)   # gold
	duration      = 10.0
	expire_time   = 15.0
	super._ready()


func get_boost_id() -> StringName:
	return &"two_points"


func activate(_car: Car) -> void:
	BoostManager.points_multiplier = 2.0


func deactivate(_car: Car) -> void:
	BoostManager.points_multiplier = 1.0
