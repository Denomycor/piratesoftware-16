class_name SonarViewport extends SubViewport


func _ready():
	world_2d = get_tree().root.get_viewport().world_2d


func _process(_delta: float) -> void:
	$sonar_camera.global_position = LevelContext.level.car.global_position
