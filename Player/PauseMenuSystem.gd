extends Node3D

@onready var player = $".."
@onready var pause_canvas : CanvasLayer = $"../Pause"
@onready var HUD_canvas : CanvasLayer = $"../HUD"
var paused : bool = false

func resume() -> void:
	paused = false
	Engine.time_scale = 1
	pause_canvas.hide()
	HUD_canvas.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_player_pause_menu_pressed():
	if !paused:
		paused = true
		Engine.time_scale = 0
		pause_canvas.show()
		HUD_canvas.hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	else:
		resume()


func _on_quit_pressed():
	get_tree().quit()

func _on_resume_pressed():
	pass # Replace with function body.
	resume()
	player.state = player.previous_state
