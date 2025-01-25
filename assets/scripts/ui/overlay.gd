class_name Overlay extends CanvasLayer

@export var point_counter: Label
@export var kills_counter: Label
@export var hp_counter: Label

func set_points(points: int) -> void:
	point_counter.text = "Points: " + str(points)

func set_kills(kills: int) -> void:
	kills_counter.text = "Kills: " + str(kills)

func set_hp(hp: int) -> void:
	hp_counter.text = "HP: " + str(hp)
