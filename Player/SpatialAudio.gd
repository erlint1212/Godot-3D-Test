class_name SpatialAudioPlayer3D extends AudioStreamPlayer3D
#Original source : https://www.youtube.com/watch?v=mHokBQyB_08&list=PLUEbHhMw9kRJPqSA_DQuzf5ucuqNNmJVB&index=8&t=93s
# Todo
# If down a step or looking through window it won't work properly

@export var max_raycast_distance : float = 30.0 # Max raycast distance before giving up
@export var update_frequency_seconds : float = 0.5 # Amount of time between each spatial audio update
@export var max_reverb_wetness : float = 0.5 # Max amount of wetness aplied to audio
@export var wall_lowpass_cutoff_amount : int = 600 # Max amount of reverb wetnss that will apply if listner is stnading behind a wall
#@export var player_path : NodePath

var _raycast_array : Array[RayCast3D] = []
var _distance_array : Array = [0,0,0,0,0,0,0,0,0,0]
var _last_update_time : float = 0.0
var _update_distances : bool = true
var _current_raycast_index : int = 0

# AUdio bus for this spatial audio player
var _audio_bus_idx = null
var _audio_bus_name = ""

#Effects
var _reverb_effect : AudioEffectReverb
var _lowpass_filter : AudioEffectLowPassFilter

# Target parameters (Will lerp over time)
var _target_lowpass_cutoff : float = 20000
var _target_reverb_room_size : float = 0.0
var _target_reverb_wetness : float = 0.0
var _target_volume_db : float = 0.0

#@onready var player : CharacterBody3D = get_node(player_path)
#@onready var player_camera : Camera3D = get_node(str(player_path) + "/Head/Camera3D")
var player_camera : Camera3D

func _ready():
	# Create an audio bus to control the effects
	_audio_bus_idx = AudioServer.bus_count
	_audio_bus_name = "SpatialBus#"+str(_audio_bus_idx)
	AudioServer.add_bus(_audio_bus_idx)
	AudioServer.set_bus_name(_audio_bus_idx, _audio_bus_name)
	AudioServer.set_bus_send(_audio_bus_idx, bus)
	self.bus = _audio_bus_name
	
	#Add the effects to the custom audio bus
	AudioServer.add_bus_effect(_audio_bus_idx, AudioEffectReverb.new(), 0)
	_reverb_effect = AudioServer.get_bus_effect(_audio_bus_idx,0)
	AudioServer.add_bus_effect(_audio_bus_idx, AudioEffectLowPassFilter.new(),1)
	_lowpass_filter = AudioServer.get_bus_effect(_audio_bus_idx, 1)
	
	#Capture the target volume, we will start from no sound adn lerp to where it should be
	_target_volume_db = volume_db
	volume_db = -60.0
	for current_raycast in self.get_children():
		current_raycast.target_position = current_raycast.target_position.normalized() * max_raycast_distance
		if current_raycast.name != "RayCastPlayer":
			_raycast_array.append(current_raycast)
	#print(_raycast_array)

func _on_update_raycast_distance(raycast : RayCast3D, raycast_index : int):
	raycast.force_raycast_update()
	var collider = raycast.get_collider()
	if collider != null:
		_distance_array[raycast_index] = global_position.distance_to(raycast.get_collision_point())
	else:
		_distance_array[raycast_index] = -1
	raycast.enabled = false # Don't let raycast runn all the time
	
func _on_update_spatial_audio(player : Node3D):
	_on_update_reverb(player)
	_on_update_lowpass_filter(player)

func _on_update_reverb(_player : Node3D):
	if _reverb_effect != null:
		# Find the reverb params
		var room_size = 0.0
		var wetness = 1.0
		for dist in _distance_array:
			if dist >= 0:
				# FInd the average room size based on the raycast distance that are valid
				room_size += (dist / max_raycast_distance) / (float(_distance_array.size()))
				room_size = min(room_size, 1.0)
			else:
				#if a raycast did not hit anything, reduce the reverb effect
				wetness -= 1.0 / float(_distance_array.size())
				wetness = max(wetness, 0.0)
		_target_reverb_wetness = wetness
		_target_reverb_room_size = room_size

func _on_update_lowpass_filter(_player : Node3D):
	if _lowpass_filter != null:
		$RayCastPlayer.target_position = (_player.global_position - global_position).normalized() * max_raycast_distance
		var collider = $RayCastPlayer.get_collider()
		var lowpass_cutoff = 20000
		if collider != null:
			#print(collider, " ", global_position, " ", $RaycastPlayer)
			var ray_distance = global_position.distance_to($RayCastPlayer.get_collision_point())
			var distance_to_player = global_position.distance_to(_player.global_position)
			var wall_to_player_ratio = ray_distance / max(distance_to_player,0.001)
			if ray_distance < distance_to_player:
				lowpass_cutoff = wall_lowpass_cutoff_amount * wall_to_player_ratio
		_target_lowpass_cutoff = lowpass_cutoff

func _lerp_parameters(delta):
	volume_db = lerp(volume_db, _target_volume_db, delta)
	_lowpass_filter.cutoff_hz = lerp(_lowpass_filter.cutoff_hz,_target_lowpass_cutoff, delta * 5.0)
	_reverb_effect.wet = lerp(_reverb_effect.wet,_target_reverb_wetness * max_reverb_wetness, delta * 5.0)
	_reverb_effect.room_size = lerp(_reverb_effect.room_size,_target_reverb_room_size,delta * 5.0)
	
func _physics_process(delta):
	_last_update_time += delta #Optimization, to not call raycast every frame
	#Should we update the raycast distance values
	if _update_distances:
		_on_update_raycast_distance(_raycast_array[_current_raycast_index], _current_raycast_index)
		_current_raycast_index += 1
		if _current_raycast_index >= _distance_array.size():
			_current_raycast_index = 0
			_update_distances = false
	
	#Check if we should update the spatial sound values
	if _last_update_time > update_frequency_seconds:
		player_camera = get_viewport().get_camera_3d()
		if player_camera != null:
			_on_update_spatial_audio(player_camera)
		_update_distances = true
		_last_update_time = 0.0
	#lerp parameters for a smooth transition
	_lerp_parameters(delta)
	
