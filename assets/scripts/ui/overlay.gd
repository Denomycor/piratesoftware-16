class_name Overlay extends CanvasLayer

@onready var point_counter: Label = %Points
@onready var kills_counter: Label = %Kills
@onready var hp_counter: Label = %Hp
@onready var speed_counter: Label = %Speed

func set_points(points: int) -> void:
	point_counter.text = "Points: " + str(points)

func set_kills(kills: int) -> void:
	kills_counter.text = "Kills: " + str(kills)

func set_speed(speed: float) -> void:
	speed_counter.text = str(speed) + " km/h"

func set_hp(hp: float) -> void:
	hp_counter.text = "HP: " + str(int(hp))

