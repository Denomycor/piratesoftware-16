class_name HookProjectile extends LinearProjectile


## Due to the need of colliding with anybody this projectile tracks hit exclusively through collisions and not hitbox_component

var target: CollisionObject2D

var my_rotation: float
var target_rotation: float


func _process(_delta: float) -> void:
	var dock: Node2D = LevelContext.level.car.get_node("weapon_dock")
	$Line2D.set_point_position(1, $Line2D.to_local(dock.global_position))

	if(frozen && target):
		# global_position = target.global_position
		# rotation = my_rotation + (target.owner.rotation - target_rotation)
		pass


func handle_hook(node: CollisionObject2D) -> void:
	if(!frozen):
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

		target = node
		# global_position = target.global_position
		target_rotation = target.rotation
		my_rotation = rotation
		if(node is Enemy):
			node.died.connect(destroy)
		if(node is Prop):
			node.destroyed.connect(destroy)



func _on_collision(collision: KinematicCollision2D) -> void:
	if(collision.get_collider() != null):
		handle_hook(collision.get_collider())

