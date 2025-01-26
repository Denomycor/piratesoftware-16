class_name Flamethrower extends Weapon

const PROJECTILE_SCENE: PackedScene = preload("res://assets/scenes/projectiles/flamethrower_projectile.tscn")

@onready var turn_component: TurnComponent = $TurnComponent
@onready var projectile_spawner_component: ProjectileSpawnerComponent = $ProjectileSpawnerComponent

@export var strength: float = 100


func _ready() -> void:
	projectile_spawner_component.shoot_projectile.connect(func(from: Vector2, rot: float, _data):
		var projectile: FlamethrowerProjectile = PROJECTILE_SCENE.instantiate()
		projectile.set_properties(from, rot)
		projectile.inherited_velocity = LevelContext.level.car.last_velocity
		LevelContext.level.get_node("World").add_child(projectile)
	)

	projectile_spawner_component.just_shot.connect(func():
		var dir: Vector2 = get_global_mouse_position().direction_to(global_position)
		fired.emit(dir * strength * projectile_spawner_component.multishot)
	)


func _process(_delta: float) -> void:
	if !active:
		return
	
	if Input.is_action_pressed("fire"):
		projectile_spawner_component.shoot(get_global_mouse_position())

