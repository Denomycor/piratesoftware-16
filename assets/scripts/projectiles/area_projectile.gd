class_name AreaProjectile extends LinearProjectile

@onready var area_hitbox_component : HitBoxComponent = $AreaHitBoxComponent

const EXPLOSION_TIME := 0.1

func _ready() -> void:
	super._ready()
	area_hitbox_component.monitoring = false


func destroy() -> void:
	if(!frozen):
		$Sprite2D.visible = false
		area_hitbox_component.monitoring = true
		frozen = true
		$CollisionShape2D.set_deferred("disabled", true)

		timer.kill()
		var area_timer := create_tween()
		area_timer.tween_callback(func(): 
			area_hitbox_component.get_node("CollisionShape2D").set_deferred("disabled", true)
			area_hitbox_component.monitoring = false
		).set_delay(EXPLOSION_TIME)

		$GPUParticles2D.emitting = true
		$GPUParticles2D.finished.connect(func():
			print("destroy")
			queue_free()
		)


func schedule_destroy() -> void:
	destroy_next_frame = true
	$Sprite2D.visible = false

