class_name Hook extends Weapon

const PROJECTILE_SCENE: PackedScene = preload("res://assets/scenes/projectiles/hook_projectile.tscn")

@onready var turn_component: TurnComponent = $TurnComponent
@onready var projectile_spawner_component: ProjectileSpawnerComponent = $ProjectileSpawnerComponent

@export var strength: float = 10

func _ready() -> void:
	projectile_spawner_component.shoot_projectile.connect(_on_hook_shoot)

func _process(_delta: float) -> void:
	if !active:
		return
	
	if Input.is_action_pressed("fire"):
		projectile_spawner_component.shoot(get_global_mouse_position())


func _on_hook_shoot(from: Vector2, rot: float, _data: Variant) -> void:
	var projectile: HookProjectile = PROJECTILE_SCENE.instantiate()
	projectile.set_properties(from, rot)
	LevelContext.level.get_node("World").add_child(projectile)

	var dir: Vector2 = get_global_mouse_position().direction_to(global_position)

	fired.emit(dir * strength)
