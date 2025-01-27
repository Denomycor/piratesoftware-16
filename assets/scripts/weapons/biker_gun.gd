class_name BikerGun extends EnemyWeapon

#using minigun projectile as placeholder until debate
const PROJECTILE_SCENE: PackedScene = preload("res://assets/scenes/projectiles/enemy_minigun_projectile.tscn")

@export var max_rotation: float = 90
@onready var turn_component: EnemyTurnComponent = $TurnComponent
@onready var projectile_spawner_component: ProjectileSpawnerComponent = $ProjectileSpawnerComponent


func _ready() -> void:
	projectile_spawner_component.shoot_projectile.connect(func(from: Vector2, rot: float, _data):
		var projectile: LinearProjectile = PROJECTILE_SCENE.instantiate()
		projectile.set_properties(from, rot)

		projectile.inherited_velocity = parent.velocity
		LevelContext.level.get_node("World").add_child(projectile)
	)


func _process(_delta: float) -> void:
	var car_position = LevelContext.level.car.global_position
	if global_position.distance_to(car_position) < activation_range:
		turn_component.activate()
	elif turn_component.active:
		turn_component.deactivate()
	
	if turn_component.active:
		var angle = parent.velocity.angle_to(global_position.direction_to(car_position))
		if abs(angle) > deg_to_rad(max_rotation):
			turn_component.lock_turn(max_rotation*sign(angle))
			projectile_spawner_component.enabled = false
		else:
			projectile_spawner_component.enabled = true
		projectile_spawner_component.shoot(car_position)

	
