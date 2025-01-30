class_name Minigun extends Weapon


const PROJECTILE_SCENE: PackedScene = preload("res://assets/scenes/projectiles/minigun_projectile.tscn")

@onready var turn_component: TurnComponent = $TurnComponent
@onready var projectile_spawner_component: ProjectileSpawnerComponent = $ProjectileSpawnerComponent

@export var strength: float = 15
@export var speed_variation: float = 1.3
func _ready() -> void:
	projectile_spawner_component.shoot_projectile.connect(func(from: Vector2, rot: float, _data):
		var projectile: LinearProjectile = PROJECTILE_SCENE.instantiate()
		projectile.set_properties(from, rot)
		projectile.inherited_velocity = LevelContext.level.car.linear_velocity
		projectile.speed = randf_range(projectile.speed, projectile.speed * speed_variation)
		LevelContext.level.get_node("World").add_child(projectile)
	)

	projectile_spawner_component.just_shot.connect(func():
		var dir: Vector2 = get_global_mouse_position().direction_to(global_position)
		fired.emit(dir * strength * projectile_spawner_component.multishot)
	)

	activated.connect(func():
		if (Input.is_action_pressed("fire")):
			%shoot.play()
	)
	deactivated.connect(func():
		%shoot.stop()
	)


func _process(_delta: float) -> void:
	if !active:
		return
	
	if Input.is_action_pressed("fire"):
		projectile_spawner_component.shoot(get_global_mouse_position())


func _input(event: InputEvent) -> void:
		if (event.is_action_pressed("fire") && active):
			$GPUParticles2D.emitting = true
			%shoot.play()
		elif (event.is_action_released("fire")):
			$GPUParticles2D.emitting = false
			%shoot.stop()
