## Timed boost: radiates damage to nearby enemies for [duration] seconds.
## An Area2D is attached to the car by BoostManager; _process in BoostManager
## applies AURA_DPS per second to every enemy body inside that area.
class_name AuraBoost extends BoostPickup

## World-space radius of the damage aura (pixels).
const AURA_RADIUS: float = 400.0
## Damage per second applied to each enemy body inside the aura.
const AURA_DPS: float = 20.0


func _ready() -> void:
	display_name  = "Aura Damage"
	display_color = Color(0.8, 0.2, 1.0, 1.0)   # purple
	duration      = 12.0
	expire_time   = 15.0
	super._ready()


func get_boost_id() -> StringName:
	return &"aura"


func activate(car: Car) -> void:
	BoostManager.setup_aura(car, AURA_RADIUS, AURA_DPS)


func deactivate(_car: Car) -> void:
	BoostManager.teardown_aura()
