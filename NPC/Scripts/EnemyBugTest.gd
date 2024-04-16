extends CharacterBody3D
signal attack_animation_finished

var player = null

const SPEED = 4.0
const HIT_PUSHBACK = [50.0, 10.0]
const TURN_SPEED = 0.5

@export var Health : int = 10
@export var MASS : int = 80
@export var player_path : NodePath
@export var damage : int = 2

var next_nav_point : Vector3

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var AxeHurtBox : CollisionShape3D = $Model/Weapon/Blade/HurtBox/AxeHeadHurtBox
@onready var visionRay : RayCast3D = $Model/Head/RayVision

var Sound_Resource : Movement_sfx_resource = Globals.footsteps_sfx["Stone"]
@onready var Audio_Streamer := $SpatialAudioPlayer3D

# possible states
enum {IDLE, CHASING, ATTACKING, SEARCHING, DEAD}
var state : int = IDLE
var seeing_player : bool = false
var player_last_spotet : Vector3

# Called when the node enters the scene tree for the first time.
func _ready():
	if player == null:
		player = get_node(player_path)
	animationPlayer.play("RESET")
	AxeHurtBox.disabled = true
	print(Sound_Resource)

func _look_at_target_interpolated(weight:float) -> void:
	var xform := transform # your transform
	xform = xform.looking_at(next_nav_point,Vector3.UP)
	transform = transform.interpolate_with(xform,weight)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	visionRay.look_at(player.global_position)

	if visionRay.is_colliding() and state != CHASING:
		if visionRay.get_collider().is_in_group("Player"):
			state = CHASING			
	elif state == CHASING:
		player_last_spotet = player.global_position
		nav_agent.set_target_position(player.global_position)
		state = SEARCHING
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Health > 0:
		match state:
			#print(global_position)
			CHASING, !SEARCHING:
				velocity = Vector3.ZERO
				nav_agent.set_target_position(player.global_position)
				next_nav_point = nav_agent.get_next_path_position()
				
				look_at(next_nav_point)
				rotate_object_local(Vector3.UP, PI)
				rotation.x = 0
				rotation.z = 0
				
				$Model/Head.look_at(player.global_position)
				$Model/Head.rotate_object_local(Vector3.UP, PI)
			
			#rotate(Vector3.UP, 90)
			#print((player.global_position - global_position).length())
				if ((player.global_position - global_position).length()) < 5.0:
					if !(animationPlayer.current_animation  == "Attack"):
						#velocity = Vector3.ZERO
						animationPlayer.play("Attack")
						await animationPlayer.animation_finished
						emit_signal("attack_animation_finished")
						
				else:
					velocity = (next_nav_point - global_position).normalized() * SPEED
				#elif animationPlayer.current_animation  == "Attack":
					#animationPlayer.play("RESET")
				
				if velocity.length() != 0.0 and ((player.global_position - global_position).length()) >= 5.0:
					if !animationPlayer.is_playing():
						animationPlayer.play("Walking")
					if Audio_Streamer.stream != Sound_Resource.running_sound:
						Audio_Streamer.stream = Sound_Resource.running_sound
						Audio_Streamer.play()
						
			!CHASING, SEARCHING:
				velocity = Vector3.ZERO
				nav_agent.set_target_position(player_last_spotet)
				next_nav_point = nav_agent.get_next_path_position()
				
				look_at(player_last_spotet)
				rotate_object_local(Vector3.UP, PI)
				rotation.x = 0
				rotation.z = 0
				
				$Model/Head.look_at(player_last_spotet)
				$Model/Head.rotate_object_local(Vector3.UP, PI)
				
				if (next_nav_point - global_position).length() > 0.1:
					velocity = (next_nav_point - global_position).normalized() * SPEED
					if Audio_Streamer.stream != Sound_Resource.running_sound:
						Audio_Streamer.stream = Sound_Resource.running_sound
						Audio_Streamer.play()
				else:
					state == IDLE
					Audio_Streamer.stop()
			
		move_and_slide()


"""
func _on_hurt_box_body_entered(body):
	print(body)
	if body.name == "Player" or body.name == "PlayerHitBox":
		print("Hit")
		var hit_length = global_position.direction_to(player.global_position).normalized() * Vector3(1.0 , 0.0, 1.0) * HIT_PUSHBACK[0]
		hit_length.y = 0
		var hit_height = Vector3.UP * HIT_PUSHBACK[1]
		body.velocity += hit_length + hit_height
		if body.has_method("Hit_Successful"):
			body.Hit_Successful(null, damage, null)
"""

func Hit_Calc(Body, Damage, collison_point):
	Health -= Damage
	print("Hit for: "+str(Damage)+", Health left: "+str(Health))
	if Health <= 0:
		# Darken eyes
		$Model/Head/RightEye.mesh.material.emission_enabled = false
		
		var pseudo_ragdoll_body = RigidBody3D.new()
		var coll = $CollisionShape3D.duplicate()
		pseudo_ragdoll_body.set_collision_layer_value(1, false)
		pseudo_ragdoll_body.set_collision_layer_value(3, true)
		pseudo_ragdoll_body.set_collision_mask_value(2, true)
		pseudo_ragdoll_body.set_collision_mask_value(3, true)
		pseudo_ragdoll_body.add_child(coll)
		var head = $Model/Head.duplicate()
		head.remove_child(get_node("StaticBody3D"))
		pseudo_ragdoll_body.add_child(head)
		var body = $Model/Body.duplicate()
		body.remove_child(get_node("StaticBody3D"))
		pseudo_ragdoll_body.mass = MASS
		pseudo_ragdoll_body.add_child(body)
		
		var pseudo_ragdoll_weapon = RigidBody3D.new()
		pseudo_ragdoll_weapon.set_collision_layer_value(1, false)
		pseudo_ragdoll_weapon.set_collision_layer_value(3, true)
		pseudo_ragdoll_weapon.set_collision_mask_value(2, true)
		pseudo_ragdoll_weapon.set_collision_mask_value(3, true)
		var coll_weapon = $Model/Weapon/CollisionShape3D.duplicate()
		coll_weapon.disabled = false
		pseudo_ragdoll_weapon.add_child(coll_weapon)
		var weapon = $Model/Weapon.duplicate()
		weapon.remove_child(get_node("HurtBox"))
		weapon.remove_child(get_node("CollisionShape3D"))
		#weapon.Blade.HurtBox.queue_free()
		#weapon.CollisionShape3D.queue_free()
		pseudo_ragdoll_weapon.add_child(weapon)
		#pseudo_ragdoll_weapon.add_child()
		#var pseudo_ragdoll_weapon = RigidBody3D.new()
		
		pseudo_ragdoll_weapon.global_position = $Model/Weapon.global_position
		pseudo_ragdoll_weapon.rotation = $Model/Weapon.rotation
		
		pseudo_ragdoll_body.global_position = global_position
		pseudo_ragdoll_body.rotation = rotation
		
		get_owner().add_child(pseudo_ragdoll_weapon)
		get_owner().add_child(pseudo_ragdoll_body)
		if collison_point != null:
			pseudo_ragdoll_body.apply_force(-global_position.direction_to(player.global_position).normalized() * 500, collison_point)
		else:
			pseudo_ragdoll_body.apply_force(-global_position.direction_to(player.global_position).normalized() * 500)
		queue_free()

func _on_ground_checker_surface_changed(sfx_resource : Movement_sfx_resource):
	Sound_Resource = sfx_resource
