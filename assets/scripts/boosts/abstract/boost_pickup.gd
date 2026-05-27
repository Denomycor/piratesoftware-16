## Abstract base for all timed boost pickups.
##
## Extends Area2D so the hook's pickup sensor (collision_mask=1) can detect it.
## Spawned in the world by EnemiesManager on enemy death. Collected when the
## Car overlaps, or hook-delivered. Once collected, the node stays in the tree
## (visual removed) while BoostManager runs the timed effect; queue_free() is
## called by BoostManager on expiry.
##
## Subclasses must override:
##   get_boost_id() -> StringName   (unique id for stacking check)
##   activate(car)                  (apply effect)
##   deactivate(car)                (undo effect)
## And in _ready():  set display_name / display_color / duration / expire_time,
##   then call  super._ready().
class_name BoostPickup extends Area2D

## Seconds the timed effect lasts once collected.
@export var duration: float = 10.0
## Label shown in the HUD timer strip.
@export var display_name: String = "Boost"
## Tint used for the pickup diamond and HUD row.
@export var display_color: Color = Color.WHITE
## Seconds before an un-collected pickup auto-expires and disappears.
@export var expire_time: float = 15.0

signal collected

var _expire_timer: Timer
var _visual: Polygon2D
var _shape_node: CollisionShape2D
var _auto_collect_enabled: bool = true


func _ready() -> void:
	collision_layer = 64  # layer 7 (bitmask 64) — dedicated pickups layer
	collision_mask  = 2   # layer 2 — player body triggers body_entered

	_build_visual()

	_expire_timer = Timer.new()
	_expire_timer.wait_time = expire_time
	_expire_timer.one_shot = true
	_expire_timer.timeout.connect(queue_free)
	add_child(_expire_timer)
	_expire_timer.start()

	body_entered.connect(_on_body_entered)


## Build a simple diamond Polygon2D as the world-space visual.
func _build_visual() -> void:
	_visual = Polygon2D.new()
	_visual.polygon = PackedVector2Array([
		Vector2(0, -60), Vector2(50, 0), Vector2(0, 60), Vector2(-50, 0)
	])
	_visual.color = display_color
	add_child(_visual)

	_shape_node = CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 70.0
	_shape_node.shape = circle
	add_child(_shape_node)


func _on_body_entered(body: Node2D) -> void:
	if body is Car and _auto_collect_enabled:
		_collect(body)


## Internal collection — removes the visual, registers effect with BoostManager.
func _collect(car: Car) -> void:
	collected.emit()
	_expire_timer.stop()
	if body_entered.is_connected(_on_body_entered):
		body_entered.disconnect(_on_body_entered)
	# Remove the pickup representation from the world.
	if is_instance_valid(_visual):
		_visual.queue_free()
	if is_instance_valid(_shape_node):
		_shape_node.queue_free()
	# Hand off to BoostManager; node lives on until deactivation.
	BoostManager.register_active_boost(self, car)


## Called by HookProjectile when it grabs this pickup mid-flight.
## Disables natural pickup so the car must wait for hook delivery.
func disable_auto_collect() -> void:
	_auto_collect_enabled = false
	_expire_timer.stop()


## Called by HookProjectile after it delivers the pickup to the car.
func deliver_to_car(car: Car) -> void:
	_collect(car)


## Override in subclasses — return a unique id for stacking / overlay keying.
func get_boost_id() -> StringName:
	return &"base_boost"


## Override — apply the boost effect to the car / game state.
func activate(_car: Car) -> void:
	pass


## Override — undo the boost effect. car may be null if the level was torn down.
func deactivate(_car: Car) -> void:
	pass
