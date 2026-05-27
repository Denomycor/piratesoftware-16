class_name BikerGun extends EnemyWeapon

#using minigun projectile as placeholder until debate
const PROJECTILE_SCENE: PackedScene = preload("res://assets/scenes/projectiles/enemy_minigun_projectile.tscn")

@export var max_rotation: float = 90
@onready var turn_component: EnemyTurnComponent = $TurnComponent
@onready var projectile_spawner_component: ProjectileSpawnerComponent = $ProjectileSpawnerComponent


func _ready() -> void:
	super()
	projectile_spawner_component.shoot_projectile.connect(func(from: Vector2, rot: float, _data):
		var projectile: LinearProjectile = PROJECTILE_SCENE.instantiate()
		projectile.set_properties(from, rot)
		projectile.inherited_velocity = owner_enemy.velocity
		LevelContext.level.world.add_child(projectile)
	)
	projectile_spawner_component.just_shot.connect(func():
		if projectile_spawner_component.bst_ready:
			%shoot.play()
		else:
			%shoot.stop()
	)

func _process(_delta: float) -> void:
	var car_position: Vector2 = LevelContext.level.car.global_position
	if global_position.distance_to(car_position) < activation_range:
		turn_component.activate()
	elif turn_component.active:
		turn_component.deactivate()

	if turn_component.active:
		var angle: float = owner_enemy.velocity.angle_to(global_position.direction_to(car_position))
		if abs(angle) > deg_to_rad(max_rotation):
			turn_component.lock_turn(max_rotation * sign(angle))
			projectile_spawner_component.enabled = false
		else:
			projectile_spawner_component.enabled = true
		projectile_spawner_component.shoot(car_position)
