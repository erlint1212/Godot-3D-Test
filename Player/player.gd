class_name Player extends CharacterBody3D

signal Fov_Changed
signal Water_State # emit when out or in to water
signal Update_Depth
signal PauseMenuPressed
signal Update_Health

# Preloading
#var walking_sound = preload("res://Sounds/Walking/WalkingOnStone.wav")
#var running_sound = preload("res://Sounds/Walking/RunningOnStone.wav")
var jump_sound = preload("res://Sounds/Jump.wav")
var fall_sound = preload("res://Sounds/Fall.wav")
var under_water_sound = preload("res://Sounds/Water/underwater_ambient.wav")
var flashlight_sfx = preload("res://Sounds/Props/Flashlight Sound Effect sfx.wav")


const SPEED = 5.0
const RUN_MULTIPLIER = 1.6
const LERP_VAL = 0.15

const DASH_SPEED = 30.0
const DASH_TIME = 0.2
const AIR_DASHES_MAX = 2
var dash_direction : Vector3
var air_dashes : int = 0

const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.01

const MASS = 80

# bob variables
const BOB_FREQ = 2 # Frequency
const BOB_AMP = 0.01 # Amplitude
var t_bob = 0.0 # Sine location

# FOV variables
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

# Water stuff
var water = null
var submerged : bool = false
var depth : float

#Weapon system
var Weapon_equipped : bool = false

var Sound_Resource : Movement_sfx_resource

@onready var head : Node3D = $Head
@onready var camera : Node3D = $Head/Camera3D
@onready var bow : AnimationPlayer = $Head/Camera3D/Weapons_Manager/FPS_Rig/Penobscot_bow2/AnimationPlayer
@onready var FPS_anim : AnimationPlayer = $Head/Camera3D/Weapons_Manager/FPS_Rig/AnimationPlayer
@onready var breathing_AudioStream : AudioStreamPlayer = $Scuba_Breathing
@onready var WaterEffects : Node3D = $WaterEffects
@onready var anim_tree : AnimationTree = $AnimationTree
@onready var player_mesh : Node3D = $Armature
@onready var step_sound : AudioStreamPlayer3D = $Footsteps
@onready var spatial_step_sound : AudioStreamPlayer3D = $SpatialFootsteps
@onready var weapon_sounds : AudioStreamPlayer3D = $Head/Camera3D/Weapons_Manager/WeaponSounds
@onready var ground_ray : RayCast3D = $GroundChecker

enum {NORMAL, DASHING, DEAD, PAUSED, CLIMBING}
var state : int = NORMAL
var max_health : int = 10
var health : int = 10
# For making pause work, suboptimal?
var previous_state : int = NORMAL

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	emit_signal("Update_Health")
	Sound_Resource = ground_ray.surface_sfx()
	if get_owner().has_node("Water"):
		water = self.get_owner().get_node("Water")
	
func _unhandled_input(event):
	if state not in [DEAD, PAUSED]:
		if event is InputEventMouseMotion:
			head.rotate_y(-event.relative.x * SENSITIVITY)
			camera.rotate_x(-event.relative.y * SENSITIVITY)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(95))
			#player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, camera.rotation.y, LERP_VAL)
			#player_mesh.global_transform.basis.y = camera.global_transform.basis.y
			player_mesh.global_rotation.y = camera.global_rotation.y

func _input(event):
	if state != DEAD:
		if Input.is_action_pressed("Dash") and state != DASHING:
			if not is_on_floor():
				air_dashes += 1
			else:
				air_dashes = 0
				
			if air_dashes <= AIR_DASHES_MAX:
				if Input.is_action_pressed("MoveForward"):
					dash_direction = (camera.global_transform.basis * Vector3.FORWARD).normalized()
				elif velocity != Vector3.ZERO:
					dash_direction = velocity.normalized()
				else:
					dash_direction = Vector3.ZERO
				
				if dash_direction != Vector3.ZERO:
					state = DASHING
					step_sound.stop()
					spatial_step_sound.stop()
					await get_tree().create_timer(DASH_TIME).timeout
					if state != DEAD:
						state = NORMAL
		if Input.is_action_just_pressed("Pause"):
			if state != PAUSED:
				previous_state = state
				state = PAUSED
			else:
				state = previous_state
			emit_signal("PauseMenuPressed")

func _physics_process(delta):
	# Orthonormalize the basis vectors
	transform = transform.orthonormalized()
	head.transform = head.transform.orthonormalized()
	camera.transform = camera.transform.orthonormalized()
	
	# Water
	if water:
		depth = water.get_height(global_position) - global_position.y
		emit_signal("Update_Depth", depth) 
		#get_owner().get_node("WorldEnvironment").environment.adjustment_brightness = 1.0 - depth/100.0
		
		if depth < 0.0:
			get_owner().get_node("DirectionalLight3D").light_energy = 1.0 #- depth/100.0
			get_owner().get_node("WorldEnvironment").environment.volumetric_fog_density = 0.0
		else:
			var bouyancy = $WaterEffects.bouyancy(depth)/MASS * delta
			var stokes_drag = 0
			velocity.y += bouyancy #+ gravity * delta
			#print("Boyancy: ", roundf($WaterEffects.bouyancy(depth)), "N")
			get_owner().get_node("DirectionalLight3D").light_energy = 1.0
			get_owner().get_node("WorldEnvironment").environment.volumetric_fog_density = 0.0
		
		if (depth >= 0.2) and submerged == false:
			submerged = true
			diving()
			if !$Ambient_Sounds.is_playing():
				$Ambient_Sounds.play()
		elif (depth < 0.2) and submerged == true:
			submerged = false
			breaking_surface()
			if $Ambient_Sounds.is_playing():
				$Ambient_Sounds.stop()
				
		if depth < 1.5:
			if depth <= 35.0:
				pass
			
	if Input.is_action_just_pressed("ToggleFlashlight"):
		var flashlight = $Head/Camera3D/FlashLight
		weapon_sounds.stream = flashlight_sfx
		weapon_sounds.play()
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
	
	# Add the gravity.
	if not is_on_floor(): #and (depth < 0.0 or depth == null)
		if state != CLIMBING:
			velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		step_sound.stream = jump_sound
		spatial_step_sound.stream = jump_sound
		step_sound.play()
		spatial_step_sound.play()
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	match state:
		DASHING:
			dash(dash_direction)
		CLIMBING:
			velocity.x = 0
			velocity.z = 0
			match [direction != Vector3.ZERO, Input.is_action_pressed("Run")]:
					[true, true]:
						if !step_sound.is_playing() or step_sound.stream != Sound_Resource.running_sound:
							step_sound.stream = Sound_Resource.running_sound
							spatial_step_sound.stream = Sound_Resource.running_sound
							step_sound.play()
							spatial_step_sound.play()
						velocity.y = (-(direction.x + direction.z)/2) * SPEED * RUN_MULTIPLIER
						$AnimationPlayer.speed_scale = RUN_MULTIPLIER
						#player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VAL)
					[true, false]:
						# Sound effect
						if !step_sound.is_playing() or step_sound.stream != Sound_Resource.walking_sound:
							step_sound.stream = Sound_Resource.walking_sound
							spatial_step_sound.stream = Sound_Resource.walking_sound
							step_sound.play()
							spatial_step_sound.play()
						
						velocity.y = (-(direction.x + direction.z)/2) * SPEED
						$AnimationPlayer.speed_scale = 1
						#player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VAL)
					_:
						if step_sound.is_playing():
							step_sound.stop()
							spatial_step_sound.stop()
						velocity.y = lerp((-(direction.x + direction.z)/2), (-(direction.x + direction.y)/2) * SPEED, delta * 7.0)
		NORMAL:
			if is_on_floor():
				match [direction != Vector3.ZERO, Input.is_action_pressed("Run")]:
					[true, true]:
						if !step_sound.is_playing() or step_sound.stream != Sound_Resource.running_sound:
							step_sound.stream = Sound_Resource.running_sound
							spatial_step_sound.stream = Sound_Resource.running_sound
							step_sound.play()
							spatial_step_sound.play()
						velocity.x = direction.x * SPEED * RUN_MULTIPLIER
						velocity.z = direction.z * SPEED * RUN_MULTIPLIER
						$AnimationPlayer.speed_scale = RUN_MULTIPLIER
						#player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VAL)
					[true, false]:
						# Sound effect
						if !step_sound.is_playing() or step_sound.stream != Sound_Resource.walking_sound:
							step_sound.stream = Sound_Resource.walking_sound
							spatial_step_sound.stream = Sound_Resource.walking_sound
							step_sound.play()
							spatial_step_sound.play()
						
						velocity.x = direction.x * SPEED
						velocity.z = direction.z * SPEED
						$AnimationPlayer.speed_scale = 1
						#player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VAL)
					_:
						if step_sound.is_playing():
							step_sound.stop()
							spatial_step_sound.stop()
						velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 7.0)
						velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 7.0)
			else:
				if step_sound.is_playing():
						step_sound.stop()
						spatial_step_sound.stop()
				velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 3.0)
				velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 3.0)
			
			# Weapon bobing
			t_bob += delta * velocity.length() * float(is_on_floor())
			$Head/Camera3D/Weapons_Manager/FPS_Rig.transform.origin = _headbob(t_bob) #camera
	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPEED * RUN_MULTIPLIER * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	
	var tween := create_tween()
	tween.tween_method(func(t): camera.fov = t, camera.fov, target_fov, delta * 8.0)
	#camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	emit_signal("Fov_Changed", [target_fov, delta])
	
	# Make the body play animation
	anim_tree.set("parameters/BlendSpace1D/blend_position", velocity.length()/SPEED)
	
	move_and_slide()

func _headbob(time : float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func diving() -> void:
	$WaterEffect.show()
	breathing_AudioStream.play()
	for child in water.get_children():
		if child is AudioStreamPlayer3D:
			child.stop()
	#water.find_child().stop()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#self.motion_mode = self.MOTION_MODE_FLOATING

func breaking_surface() -> void:
	$WaterEffect.hide()
	velocity.y = 0.0
	breathing_AudioStream.stop()
	for child in water.get_children():
		if child is AudioStreamPlayer3D:
			child.play()
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func dash(direction : Vector3) -> void:
	velocity = direction * DASH_SPEED


func _on_ground_checker_surface_changed(sfx_resource : Movement_sfx_resource):
	Sound_Resource = sfx_resource

func Hit_Calc(Body, damage, collison_point):
	health -= damage
	emit_signal("Update_Health")
