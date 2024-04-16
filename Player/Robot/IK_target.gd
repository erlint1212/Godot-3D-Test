extends Marker3D

@export var step_target : Node3D
@export var step_distance : float = 3.0
@export var soundStream : AudioStreamPlayer3D

@export var adjecent_target : Node3D
@export var opposite_target : Node3D

var is_stepping = false
#@onready var soundStream = $"../../AudioStreamPlayer3D"
@onready var stepSound = preload("res://Sounds/RobotWalking/Metal_Impact.wav")

func _physics_process(delta):
	if !is_stepping and !adjecent_target.is_stepping and abs(global_position.distance_to(step_target.global_position)) > step_distance:
		step()
		opposite_target.step()

func step():
	var target_pos = step_target.global_position
	var half_way = (global_position + target_pos) / 2
	is_stepping = true
	
	var t = get_tree().create_tween()
	t.tween_property(self, "global_position", half_way + owner.basis.y, 0.1)
	t.tween_property(self, "global_position", target_pos, 0.1)
	t.tween_callback(func() : is_stepping = false)
	await t.finished
	step_sound()

func step_sound():
	soundStream.stream = stepSound
	soundStream.play()
