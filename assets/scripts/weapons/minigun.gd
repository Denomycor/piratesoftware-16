class_name Minigun extends Weapon


const PROJECTILE_SCENE: PackedScene = preload("res://assets/scenes/projectiles/minigun_projectile.tscn")

@onready var turn_component: TurnComponent = $TurnComponent
@onready var projectile_spawner_component: ProjectileSpawnerComponent = $ProjectileSpawnerComponent



func _ready() -> void:
	projectile_spawner_component.shoot_projectile.connect(func(from: Vector2, rot: float, _data):
		var projectile: MinigunProjectile = PROJECTILE_SCENE.instantiate()
		projectile.set_properties(from, rot)
		get_node("../..").add_child(projectile)
	)


func _process(_delta: float) -> void:
	projectile_spawner_component.shoot(get_global_mouse_position())

