class_name gameOptions extends Node

var sound_on: Array[bool] = [true, true, true, true]
var sound_db: Array[float] = [40, 40, 40, 40]
var is_fullscreen: bool = false
var ui_scale: float = 1.0

func _ready():
    is_fullscreen = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)


func change_ui_scale(new_scale: float) -> void:
    ui_scale = new_scale / 100.0
    
    if LevelContext.level != null:
        LevelContext.level.overlay.scale_ui(ui_scale)