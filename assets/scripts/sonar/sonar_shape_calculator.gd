class_name SonarShapeCalculator extends Node2D


@export var shapes: Array[CollisionPolygon2D]


func _ready() -> void:
	for collision in shapes:
		var polygon := Polygon2D.new()
		polygon.polygon = collision.polygon
		collision.add_child(polygon)
		
		polygon.visibility_layer = 2**9

		collision.set_visibility_layer_bit(9, true)
		collision.visible = true

		var parent: Node2D = collision.get_parent()
		while(parent != owner):
			parent.set_visibility_layer_bit(9, true)
			parent = parent.get_parent()
		parent.set_visibility_layer_bit(9, true)

