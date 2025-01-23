class_name Shotgun extends Weapon

const PROJECTILE_SCENE: PackedScene = preload("res://assets/scenes/projectiles/shotgun_projectile.tscn")

@onready var turn_component: TurnComponent = $TurnComponent
@onready var projectile_spawner_component: ProjectileSpawnerComponent = $ProjectileSpawnerComponent

@export_range(0,1) var speed_variation: float


func _ready() -> void:
	projectile_spawner_component.shoot_projectile.connect(func(from: Vector2, rot_angle: float, _data):
		var projectile: LinearProjectile = PROJECTILE_SCENE.instantiate()
		projectile.speed = randf_range(projectile.speed * speed_variation, projectile.speed)
		projectile.set_properties(from, rot_angle)
		get_node("../..").add_child(projectile)
	)



func _process(_delta: float) -> void:
	if(active):
		projectile_spawner_component.shoot(get_global_mouse_position())


#temporary func to test shooting
func _input(event: InputEvent) -> void:
	if(event is InputEventMouseButton):
		var e : InputEventMouseButton = event
		if(e.button_index == MOUSE_BUTTON_LEFT):
			projectile_spawner_component.shoot(get_global_mouse_position())
