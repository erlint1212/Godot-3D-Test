extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_kill_box_body_entered(body):
	if body.name == "Player":
		body.position = Vector3(0,1.0,0)
