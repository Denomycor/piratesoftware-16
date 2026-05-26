class_name HookProjectile extends LinearProjectile


## Due to the need of colliding with anybody this projectile tracks hit exclusively
## through collisions and not hitbox_component.

## Pull force (N) applied to the Car when hooked to a wall. Tunable.
const WALL_PULL_FORCE: float = 6000.0
## Pull force (N) applied to a Barrel toward the Car. Tunable.
const BARREL_PULL_FORCE: float = 4000.0
## Barrel is released when it arrives within this distance of the Car (px). Tunable.
const BARREL_ARRIVAL_DISTANCE: float = 250.0
## Speed (px/s) at which a hooked Repair travels toward the Car. Tunable.
const REPAIR_PULL_SPEED: float = 2000.0
## Trigger Repair pickup when within this distance of the Car (px). Tunable.
const REPAIR_ARRIVAL_DISTANCE: float = 250.0
## Heal amount delivered when a Repair is hook-retrieved.
## Mirrors the damage_amount=-350 on repair.tscn's HitBoxComponent.
const REPAIR_HEAL_AMOUNT: float = -350.0

var target: CollisionObject2D = null
var anchor: Node2D

var my_rotation: float
var target_rotation: float

## Runtime Area2D sensor used to detect Area2D-based pickups (Repair, future boosts).
## move_and_collide() cannot reach Area2D nodes, so we poll this sensor each frame.
var _pickup_sensor: Area2D


func _ready() -> void:
	super._ready()
	# Build sensor at runtime to avoid fragile .tscn edits.
	_pickup_sensor = Area2D.new()
	_pickup_sensor.collision_layer = 0
	_pickup_sensor.collision_mask = 1  # layer 1 — Repair (and other prop Area2Ds)
	_pickup_sensor.monitorable = false
	var shape_node := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 80.0  # large enough to survive a fast-moving hook frame
	shape_node.shape = circle
	_pickup_sensor.add_child(shape_node)
	add_child(_pickup_sensor)


func _process(_delta: float) -> void:
	# While flying (no target yet), poll the sensor for Area2D pickups.
	# Signal-based area_entered can miss fast-moving objects; polling is reliable.
	if target == null and not frozen:
		for area in _pickup_sensor.get_overlapping_areas():
			if area is Repair:
				connect_hook(area, area.global_position)
				break

	if target:
		global_position = anchor.global_position
		rotation = my_rotation + (target.rotation - target_rotation)

		if LevelContext.level.car.global_position.distance_to(global_position) > 6000:
			destroy()

	var dock: Node2D = LevelContext.level.car.get_node("weapon_dock")
	$Line2D.set_point_position.call_deferred(1, $Line2D.to_local(dock.global_position))


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if not target:
		return

	var car := LevelContext.level.car

	if target is Enemy:
		# Pull the enemy toward the Car (original behavior, preserved).
		if target.global_position.distance_to(car.global_position) > 800:
			var direction_to_car := target.global_position.direction_to(car.global_position)
			var car_direction := car.linear_velocity.normalized()
			var hook_pull := direction_to_car * 500 + car.linear_velocity * direction_to_car.dot(car_direction)
			target.velocity = hook_pull
			target.move_and_slide()
		else:
			var direction_to_car := target.global_position.direction_to(car.global_position)
			var car_direction := car.linear_velocity.normalized()
			var hook_pull := car.linear_velocity * direction_to_car.dot(car_direction)
			target.velocity = hook_pull
			target.move_and_slide()

	elif target is Barrel:
		# Drag the barrel toward the Car by applying force to its RigidBody2D.
		var barrel := target as Barrel
		var dist := barrel.global_position.distance_to(car.global_position)
		if dist > BARREL_ARRIVAL_DISTANCE:
			var dir := barrel.global_position.direction_to(car.global_position)
			barrel.rigid_body.apply_central_force(dir * BARREL_PULL_FORCE)
		else:
			destroy()  # close enough — detach

	elif target is Repair:
		# Move the Repair prop toward the Car directly (it's an Area2D, no physics).
		# anchor is a child of target and moves automatically when target moves.
		var dist := target.global_position.distance_to(car.global_position)
		if dist > REPAIR_ARRIVAL_DISTANCE:
			var dir := target.global_position.direction_to(car.global_position)
			target.global_position += dir * REPAIR_PULL_SPEED * delta
		else:
			# Arrived — heal directly (don't rely on HitBox/HurtBox timing).
			car.hurt_box.take_damage(REPAIR_HEAL_AMOUNT)
			(target as Repair)._on_collision(0.0)  # VFX + schedule queue_free
			destroy()

	elif target is StaticBody2D:
		# Pull the Car toward the wall anchor point.
		var dir := car.global_position.direction_to(anchor.global_position)
		car.apply_central_force(dir * WALL_PULL_FORCE)


func connect_hook(node: CollisionObject2D, pos: Vector2) -> void:
	# Stop lifetime countdown
	timer.kill()
	# Stop fade-out effect
	scale_tween.kill()
	# Restore scale (scale_tween may have shrunk it)
	scale = Vector2.ONE
	# Stop self-movement
	frozen = true
	# Disable own collision shape (we're now stationary)
	$CollisionShape2D.set_deferred("disabled", true)
	# Disable pickup sensor — we're already attached
	_pickup_sensor.set_deferred("monitoring", false)

	target = node

	# Anchor is a child of the target so it follows target movement automatically.
	anchor = Node2D.new()
	target.add_child(anchor)
	anchor.global_position = pos

	global_position = anchor.global_position
	target_rotation = target.rotation
	my_rotation = rotation

	if node is Enemy:
		node.died.connect(destroy)
		node.movement_locked = true
	if node is Prop:
		node.destroyed.connect(destroy)
	if node is Repair:
		# Disable natural pickup so the Repair doesn't heal the car on its own
		# while being towed — we apply healing directly on arrival.
		(node as Repair).hit_box.monitoring = false
	z_index = 0


func _on_collision(collision: KinematicCollision2D) -> void:
	if collision.get_collider() != null:
		connect_hook(collision.get_collider(), collision.get_position())


func destroy() -> void:
	super.destroy()
	if anchor:
		if target is Enemy:
			target.movement_locked = false
		anchor.queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("release"):
		destroy()
