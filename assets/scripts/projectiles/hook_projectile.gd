class_name HookProjectile extends LinearProjectile


## Due to the need of colliding with anybody this projectile tracks hit exclusively through collisions and not hitbox_component

var target: CollisionObject2D = null
var anchor: Node2D

var my_rotation: float
var target_rotation: float


func _process(_delta: float) -> void:
	if(target):
		global_position = anchor.global_position
		rotation = my_rotation + (target.rotation - target_rotation)

		if(LevelContext.level.car.global_position.distance_to(global_position) > 6000):
			destroy()

	var dock: Node2D = LevelContext.level.car.get_node("weapon_dock")
	$Line2D.set_point_position.call_deferred(1, $Line2D.to_local(dock.global_position))


func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	if(target is Enemy):
		if(target.global_position.distance_to(LevelContext.level.car.global_position) > 800):
			var direction_to_car := target.global_position.direction_to(LevelContext.level.car.global_position)
			var car_direction := LevelContext.level.car.linear_velocity.normalized()
			var hook_pull := direction_to_car * 500 + LevelContext.level.car.linear_velocity * direction_to_car.dot(car_direction)
			target.velocity = hook_pull
			target.move_and_slide()
		else:
			var direction_to_car := target.global_position.direction_to(LevelContext.level.car.global_position)
			var car_direction := LevelContext.level.car.linear_velocity.normalized()
			var hook_pull := LevelContext.level.car.linear_velocity * direction_to_car.dot(car_direction)
			target.velocity = hook_pull
			target.move_and_slide()


func connect_hook(node: CollisionObject2D, pos: Vector2) -> void:
	# stop lifetime timer
	timer.kill()
	# stop fade effect
	scale_tween.kill()
	# restore scale
	scale = Vector2.ONE
	# stop movement
	frozen = true
	# stop collisions
	$CollisionShape2D.set_deferred("disabled", true)

	# save the target we are hooking
	target = node

	# create the anchor
	anchor = Node2D.new()
	target.add_child(anchor)
	anchor.global_position = pos

	global_position = anchor.global_position
	target_rotation = target.rotation
	my_rotation = rotation
	if(node is Enemy):
		node.died.connect(destroy)
		node.movement_locked = true
	if(node is Prop):
		node.destroyed.connect(destroy)
	z_index = 0



func _on_collision(collision: KinematicCollision2D) -> void:
	if(collision.get_collider() != null):
		connect_hook(collision.get_collider(), collision.get_position())


func destroy() -> void:
	super.destroy()
	if(anchor):
		if(target is Enemy):
			target.movement_locked = false
		anchor.queue_free()


func _input(event: InputEvent) -> void:
	if(event.is_action_pressed("release")):
		destroy()

