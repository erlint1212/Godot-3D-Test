extends Node3D

@export var right : bool = false

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var open_sfx : AudioStreamWAV = preload("res://Sounds/Props/Door/OpeningDoor.wav")
@onready var close_sfx : AudioStreamWAV = preload("res://Sounds/Props/Door/CloseDoor.wav")
@onready var audio_player : AudioStreamPlayer3D = $Hinge/Node3D/SpatialAudioPlayer3D

var open : bool = false

func interact_door() -> void:
	if open:
		close()
		open = false
		audio_player.stream = close_sfx
		audio_player.play()
	elif !open:
		open_door()
		open = true
		audio_player.stream = open_sfx
		audio_player.play()
	else:
		push_error("open bool not working")

func close() -> void:
	if right:
		animation_player.play_backwards("open_door")
	elif !right:
		animation_player.play_backwards("open_door_right")

func open_door() -> void:
	if right:
		animation_player.play("open_door")
	if !right:
		animation_player.play("open_door_right")
	
