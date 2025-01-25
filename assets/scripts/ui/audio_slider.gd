class_name AudioSlider extends Control


const MAX_DB := 30.0
const MIN_DB := -20.0


@onready var audio_enabled: CheckBox = $HBoxContainer/CheckBox
@onready var slider: HSlider = $HBoxContainer/HSlider
@onready var label: Label = $HBoxContainer/Label

@export var bus_name: String
@export var bus_idx: int


var prev_mute_val: float


func _ready():
	slider.value_changed.connect(change_volume)
	audio_enabled.toggled.connect(disable_mute)
	
	load_settings()

	$Label.text = bus_name
	prev_mute_val = slider.value



func change_volume(volume: float) -> void:
	# we slided the volume to zero, mute
	if(audio_enabled.button_pressed && volume == 0):
		audio_enabled.set_pressed_no_signal(false)
		disable_mute(false)

	# we slided the volume when we were muted, unmute
	elif(!audio_enabled.button_pressed && volume != 0):
		disable_mute(true, volume)

	else:
		var value: float = lerp(MIN_DB, MAX_DB, volume/100)
		AudioServer.set_bus_volume_db(bus_idx, value)

		label.text = str(volume)
		set_settings()


func disable_mute(is_disabled: bool, volume := prev_mute_val) -> void:
	AudioServer.set_bus_mute(bus_idx, !is_disabled)
	if(!is_disabled):
		prev_mute_val = slider.value
		slider.set_value_no_signal(0)
		label.text = "0"
	else:
		audio_enabled.set_pressed_no_signal(true)
		slider.set_value_no_signal(max(1,min(prev_mute_val, volume)))
		change_volume(max(1,min(prev_mute_val, volume)))
	set_settings()


func load_settings() -> void:
	label.text = str(GameOptions.sound_db[bus_idx])
	slider.set_value_no_signal(GameOptions.sound_db[bus_idx])
	audio_enabled.set_pressed_no_signal(GameOptions.sound_on[bus_idx])


func set_settings() -> void:
	GameOptions.sound_db[bus_idx] = slider.value
	GameOptions.sound_on[bus_idx] = audio_enabled.button_pressed
