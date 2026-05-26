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

## Runtime Area2D sensor for detecting Area2D-based pickups (Repair, future boosts).
## Created lazily on the first _process frame to avoid overriding _ready().
var _pickup_sensor: Area2D = null


func _process(_delta: float) -> void:
	# Build pickup sensor on the very first frame (lazy init avoids _ready override).
	if _pickup_sensor == null:
		_pickup_sensor = Area2D.new()
		_pickup_sensor.collision_layer = 0
		_pickup_sensor.collision_mask = 1   # layer 1 — Repair root Area2D is on layer 1 (default)
		_pickup_sensor.monitorable = false
		var shape_node := CollisionShape2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 80.0
		shape_node.shape = circle
		_pickup_sensor.add_child(shape_node)
		add_child(_pickup_sensor)

	# While flying (no valid target yet), poll the sensor for Area2D pickups.
	# is_instance_valid() guards against freed-but-non-null objects.
	# Polling get_overlapping_areas() is more reliable than area_entered signals
	# for fast-moving projectiles that might cross an Area in a single frame.
	#
	# NOTE: get_overlapping_areas() returns Array[Area2D], so the loop variable is
	# statically typed Area2D. GDScript 4.6 rejects "area is Repair" directly because
	# Repair extends CollisionObject2D (not Area2D). Widen to CollisionObject2D first —
	# both Area2D and Repair share that ancestor, so the narrowing check is valid.
	if not is_instance_valid(target) and not frozen:
		for area in _pickup_sensor.get_overlapping_areas():
			var col: CollisionObject2D = area  # Area2D → CollisionObject2D (safe widening)
			if col is Repair:
				connect_hook(col, col.global_position)
				break

	if is_instance_valid(target):
		global_position = anchor.global_position
		rotation = my_rotation + (target.rotation - target_rotation)

		if LevelContext.level.car.global_position.distance_to(global_position) > 6000:
			destroy()

	var dock: Node2D = LevelContext.level.car.get_node("weapon_dock")
	$Line2D.set_point_position.call_deferred(1, $Line2D.to_local(dock.global_position))


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if not is_instance_valid(target):
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
			destroy()   # close enough — detach

	elif target is Repair:
		# Move the Repair prop toward the Car (it's an Area2D; set position directly).
		# anchor is a child of target, so it follows automatically when target moves.
		var dist := target.global_position.distance_to(car.global_position)
		if dist > REPAIR_ARRIVAL_DISTANCE:
			var dir := target.global_position.direction_to(car.global_position)
			target.global_position += dir * REPAIR_PULL_SPEED * delta
		else:
			# Arrived — heal Car directly, trigger Repair VFX, then detach.
			car.hurt_box.take_damage(REPAIR_HEAL_AMOUNT)
			var repair := target as Repair
			repair._on_collision(0.0)
			destroy()

	elif target is StaticBody2D:
		# Pull the Car toward the wall anchor point.
		var dir := car.global_position.direction_to(anchor.global_position)
		car.apply_central_force(dir * WALL_PULL_FORCE)


func connect_hook(node: CollisionObject2D, pos: Vector2) -> void:
	# Stop lifetime countdown.
	timer.kill()
	# Stop fade-out scale effect (guard: scale_tween is null when scale_curve is unset).
	if scale_tween != null:
		scale_tween.kill()
	# Restore scale (scale_tween may have begun shrinking it).
	scale = Vector2.ONE
	# Freeze movement.
	frozen = true
	# Disable own collision shape (stationary from here).
	$CollisionShape2D.set_deferred("disabled", true)
	# Disable pickup sensor — we have a target now.
	if is_instance_valid(_pickup_sensor):
		_pickup_sensor.set_deferred("monitoring", false)

	target = node

	# Anchor is a child of target so it follows target movement automatically.
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
		# Disable natural pickup while being towed to prevent a double-heal.
		var repair := node as Repair
		repair.hit_box.monitoring = false
	z_index = 0


func _on_collision(collision: KinematicCollision2D) -> void:
	if collision.get_collider() != null:
		connect_hook(collision.get_collider(), collision.get_position())


func destroy() -> void:
	super.destroy()
	if is_instance_valid(anchor):
		if is_instance_valid(target) and target is Enemy:
			target.movement_locked = false
		anchor.queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("release"):
		destroy()
