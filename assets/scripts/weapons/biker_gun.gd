class_name BikerGun extends EnemyWeapon

#using minigun projectile as placeholder until debate
const PROJECTILE_SCENE: PackedScene = preload("res://assets/scenes/projectiles/minigun_projectile.tscn")

@onready var turn_component: EnemyTurnComponent = $TurnComponent
@onready var projectile_spawner_component: ProjectileSpawnerComponent = $ProjectileSpawnerComponent


func _ready() -> void:
	projectile_spawner_component.shoot_projectile.connect(func(from: Vector2, rot: float, _data):
		var projectile: LinearProjectile = PROJECTILE_SCENE.instantiate()
		projectile.set_properties(from, rot)

		LevelContext.level.get_node("World").add_child(projectile)
	)


func _process(_delta: float) -> void:
	if global_position.distance_to(LevelContext.level.car.global_position) < activation_range:
		turn_component.activate()
		projectile_spawner_component.shoot(LevelContext.level.car.global_position)
	elif turn_component.active:
		turn_component.deactivate(get_enemy_direction())
