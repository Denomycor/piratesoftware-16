class_name Shotgun extends Weapon

const PROJECTILE_SCENE: PackedScene = preload("res://assets/scenes/projectiles/shotgun_projectile.tscn")

@onready var turn_component: TurnComponent = $TurnComponent
@onready var projectile_spawner_component: ProjectileSpawnerComponent = $ProjectileSpawnerComponent

@export_range(0, 1) var speed_variation: float

@export var strength: float = 200

func _ready() -> void:
	projectile_spawner_component.shoot_projectile.connect(func(from: Vector2, rot_angle: float, _data):
		var projectile: LinearProjectile = PROJECTILE_SCENE.instantiate()
		projectile.speed = randf_range(projectile.speed * speed_variation, projectile.speed)
		projectile.set_properties(from, rot_angle)
		LevelContext.level.get_node("World").add_child(projectile)
	)

	projectile_spawner_component.just_shot.connect(func():
		var dir: Vector2 = get_global_mouse_position().direction_to(global_position)
		fired.emit(dir * strength * projectile_spawner_component.multishot)
	)


func _process(_delta: float) -> void:
	if !active:
		return

	if Input.is_action_just_pressed("fire"):
		projectile_spawner_component.shoot(get_global_mouse_position())
