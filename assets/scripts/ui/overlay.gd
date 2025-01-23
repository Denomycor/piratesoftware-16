class_name Overlay extends CanvasLayer

@export var point_counter: Label

func set_points(points: int) -> void:
	point_counter.text = str(points)
