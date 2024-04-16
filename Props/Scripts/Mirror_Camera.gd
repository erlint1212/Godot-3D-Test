extends Node3D

@export var player : NodePath
@onready var player_camera : Camera3D = get_node(str(player) + "/Head/Camera3D")
@onready var mirror_camera : Camera3D = $MirrorMesh/SubViewport/Camera3D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var new_transelation = player_camera.global_position - mirror_camera.global_position
	new_transelation.x = -new_transelation.x
	mirror_camera.global_position = new_transelation
	
	var new_rotation = player_camera.rotation
	new_rotation.y = -new_rotation.y
	mirror_camera.rotation = new_rotation
