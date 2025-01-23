class_name Minigun extends Weapon


const PROJECTILE_SCENE: PackedScene = preload("res://assets/scenes/projectiles/minigun_projectile.tscn")

@onready var turn_component: TurnComponent = $TurnComponent
@onready var projectile_spawner_component: ProjectileSpawnerComponent = $ProjectileSpawnerComponent

const STRENGTH: float = 500

func _ready() -> void:
	projectile_spawner_component.shoot_projectile.connect(func(from: Vector2, rot: float, _data):
		var projectile: LinearProjectile = PROJECTILE_SCENE.instantiate()
		projectile.set_properties(from, rot)
		LevelContext.level.get_node("World").add_child(projectile)

		var dir: Vector2 = get_global_mouse_position().direction_to(global_position)


		fired.emit(-dir * STRENGTH)
	)


func _input(event: InputEvent) -> void:
	if !active:
		return

	if (event is InputEventMouseButton):
		var e: InputEventMouseButton = event
		if (e.button_index == MOUSE_BUTTON_LEFT && e.pressed):
			projectile_spawner_component.shoot(get_global_mouse_position())
