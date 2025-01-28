class_name HookProjectile extends LinearProjectile


## Due to the need of colliding with anybody this projectile tracks hit exclusively through collisions and not hitbox_component

var target: CollisionObject2D = null
var anchor: Node2D

var my_rotation: float
var target_rotation: float


func _process(_delta: float) -> void:
	var dock: Node2D = LevelContext.level.car.get_node("weapon_dock")
	$Line2D.set_point_position(1, $Line2D.to_local(dock.global_position))

	if(target):
		global_position = anchor.global_position
		rotation = my_rotation + (target.rotation - target_rotation)


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	var dock: Node2D = LevelContext.level.car.get_node("weapon_dock")
	$Line2D.set_point_position(1, $Line2D.to_local(dock.global_position))


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
	if(node is Prop):
		node.destroyed.connect(destroy)



func _on_collision(collision: KinematicCollision2D) -> void:
	if(collision.get_collider() != null):
		connect_hook(collision.get_collider(), collision.get_position())


func destroy() -> void:
	super.destroy()
	if(anchor):
		target.queue_free()

