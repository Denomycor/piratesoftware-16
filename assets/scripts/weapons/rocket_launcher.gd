class_name RocketLauncher extends Weapon

const PROJECTILE_SCENE: PackedScene = preload("res://assets/scenes/projectiles/rocketlauncher_projectile.tscn")

@onready var turn_component: TurnComponent = $TurnComponent
@onready var projectile_spawner_component: ProjectileSpawnerComponent = $ProjectileSpawnerComponent

func _ready() -> void:
	projectile_spawner_component.shoot_projectile.connect(func(from: Vector2, rot: float, _data):
		var projectile: LinearProjectile = PROJECTILE_SCENE.instantiate()
		projectile.set_properties(from, rot)
		get_node("../..").add_child(projectile)
	)

#temporary func to test shooting
func _input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		var e : InputEventMouseButton = event
		if(e.button_index == MOUSE_BUTTON_LEFT):
			projectile_spawner_component.shoot(get_global_mouse_position())
