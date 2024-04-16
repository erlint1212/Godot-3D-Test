extends Control

var progress = []
var sceneName
var scene_load_status = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	sceneName = Globals.next_scene
	$Control/VBoxContainer/HBoxContainer/sceneName.text = Globals.next_scene_name
	ResourceLoader.load_threaded_request(sceneName)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	scene_load_status = ResourceLoader.load_threaded_get_status(sceneName, progress)
	$Control/VBoxContainer/ProgressBar.value = progress[0]*100
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var newScene = ResourceLoader.load_threaded_get(sceneName)
		get_tree().change_scene_to_packed(newScene)
