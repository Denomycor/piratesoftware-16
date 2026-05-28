class_name LoadingScreen extends CanvasLayer

## Async loading screen with shader warmup.
##
## Usage:
##   loading_screen.loading_complete.connect(my_callback)
##   loading_screen.start_loading("res://assets/scenes/levels/test_level.tscn")
##
## The signal fires with the loaded PackedScene once loading AND shader warmup
## are both complete. The caller is responsible for instantiating the scene.

signal loading_complete(packed_scene: PackedScene)

## All shaders that should be force-compiled before gameplay starts.
## Each entry is warmed by rendering a ColorRect with that ShaderMaterial
## inside a hidden 8×8 SubViewport for two frames.
const WARMUP_SHADER_PATHS: Array[String] = [
	"res://assets/resources/shaders/test_level.gdshader",   # arena background (uses SCREEN_TEXTURE)
	"res://assets/scripts/scrolling_texture.gdshader",      # wheel sprites (car + biker)
	"res://assets/scripts/sonar/sonar.gdshader",            # sonar viewport (uses SCREEN_TEXTURE)
	"res://assets/scripts/ui/vignette.gdshader",            # overlay vignette
	"res://assets/scripts/circle.gdshader",                 # car shape
]

@onready var progress_bar: ProgressBar = $CenterContainer/VBoxContainer/ProgressBar
@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel

var _scene_path: String


func _ready() -> void:
	visible = false
	set_process(false)


## Call this to begin async loading. The loading_complete signal fires when done.
func start_loading(scene_path: String) -> void:
	_scene_path = scene_path
	progress_bar.value = 0
	status_label.text = "Loading..."
	visible = true
	ResourceLoader.load_threaded_request(scene_path)
	set_process(true)


func _process(_delta: float) -> void:
	var progress: Array = []
	var status := ResourceLoader.load_threaded_get_status(_scene_path, progress)

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if progress.size() > 0:
				# Scale load progress to 0–85; leave 15% for warmup
				progress_bar.value = progress[0] * 85.0

		ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			progress_bar.value = 85.0
			status_label.text = "Warming up shaders..."
			_do_shader_warmup.call_deferred()

		ResourceLoader.THREAD_LOAD_FAILED, ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			push_error("LoadingScreen: failed to load '%s'" % _scene_path)
			set_process(false)


## Creates a tiny hidden SubViewport with one ColorRect per shader.
## Waiting two frames forces the GPU to compile all shader variants here
## instead of on first gameplay encounter (which causes stutter).
func _do_shader_warmup() -> void:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(8, 8)
	viewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	add_child(viewport)

	for shader_path in WARMUP_SHADER_PATHS:
		var shader: Shader = load(shader_path)
		if shader == null:
			push_warning("LoadingScreen: shader not found: " + shader_path)
			continue
		var mat := ShaderMaterial.new()
		mat.shader = shader
		var rect := ColorRect.new()
		rect.size = Vector2(8.0, 8.0)
		rect.material = mat
		viewport.add_child(rect)

	progress_bar.value = 92.0

	# Two frames: first to submit draw calls, second for the GPU to finish
	await get_tree().process_frame
	await get_tree().process_frame

	viewport.queue_free()
	progress_bar.value = 100.0
	status_label.text = "Ready!"

	# Small pause so the player can see 100% before the screen disappears
	await get_tree().create_timer(0.3).timeout

	var packed_scene: PackedScene = ResourceLoader.load_threaded_get(_scene_path)
	visible = false
	loading_complete.emit(packed_scene)
