class_name gameOptions extends Node

var sound_on: Array[bool] = [true, true, true]
var sound_db: Array[float] = [40, 40, 40]
var is_fullscreen: bool = false


func _ready():
    is_fullscreen = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
