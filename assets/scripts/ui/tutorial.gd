class_name Tutorial extends CanvasLayer

var crawler_scene: PackedScene = preload("res://assets/scenes/enemies/crawler.tscn")
var minigun_scene: PackedScene = preload("res://assets/scenes/weapons/minigun.tscn")
var rocket_projectile_scene: PackedScene = preload("res://assets/scenes/projectiles/rocketlauncher_projectile.tscn")
var flamethrower_projectile_scene: PackedScene = preload("res://assets/scenes/projectiles/flamethrower_projectile.tscn")
var shotgun_projectile_scene: PackedScene = preload("res://assets/scenes/projectiles/shotgun_projectile.tscn")
var barrel_scene: PackedScene = preload("res://assets/scenes/props/barrel1.tscn")


@onready var timer := $Timer

func _ready() -> void:
	var crawler: Crawler = crawler_scene.instantiate()
	crawler.position = Vector2(0, 0)
	crawler.visible = false

	var minigun: Minigun = minigun_scene.instantiate()
	minigun.position = Vector2(100, 0)
	minigun.visible = false

	var rocket_projectile = rocket_projectile_scene.instantiate()
	rocket_projectile.position = Vector2(200, 0)
	rocket_projectile.visible = false

	var flamethrower_projectile: FlamethrowerProjectile = flamethrower_projectile_scene.instantiate()
	flamethrower_projectile.position = Vector2(300, 0)
	flamethrower_projectile.visible = false

	var shotgun_projectile = shotgun_projectile_scene.instantiate()
	shotgun_projectile.position = Vector2(400, 0)
	shotgun_projectile.visible = false

	var barrel: Barrel = barrel_scene.instantiate()
	barrel.position = Vector2(500, 0)
	barrel.visible = false

	get_tree().get_root().add_child.call_deferred(crawler)
	get_tree().get_root().add_child.call_deferred(minigun)
	get_tree().get_root().add_child.call_deferred(rocket_projectile)
	get_tree().get_root().add_child.call_deferred(flamethrower_projectile)
	get_tree().get_root().add_child.call_deferred(shotgun_projectile)
	get_tree().get_root().add_child.call_deferred(barrel)

	crawler.load_particles()
	minigun.load_particles()
	barrel.load_particles()

	crawler.queue_free()
	minigun.queue_free()
	rocket_projectile.queue_free()
	flamethrower_projectile.queue_free()
	shotgun_projectile.queue_free()
	barrel.queue_free()

	timer.timeout.connect(play.emit)

signal play

func start() -> void:
	visible = true
	timer.start()

func _input(event):
	if event is InputEventKey:
		if event.pressed and (event.keycode == KEY_ESCAPE || event.keycode == KEY_SPACE || event.keycode == KEY_ENTER):
			play.emit()
			timer.stop()
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			play.emit()
			timer.stop()
