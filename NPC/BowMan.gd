extends CharacterBody3D

var player = null

const SPEED = 4.0
const HIT_PUSHBACK = [50.0, 10.0]
const TURN_SPEED = 0.5

@export var Health : int = 10
@export var MASS : int = 80
@export var player_path : NodePath
@export var attack_range : int = 5
@export var vision_range : int = 300

var next_nav_point : Vector3

@onready var nav_agent : NavigationAgent3D = $NavigationAgent3D
@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var animationPlayer : AnimationPlayer = $AnimationPlayer
@onready var animationPlayer_bow : AnimationPlayer = $Model/Head/Weapon/Penobscot_bow2/AnimationPlayer
@onready var AxeHurtBox : CollisionShape3D = $Model/Weapon/Blade/HurtBox/AxeHeadHurtBox
@onready var visionRay : RayCast3D = $Model/Head/RayVision
@onready var Shoot_Point : Marker3D = %ArrowSpawnPoint
@onready var audio_bow : SpatialAudioPlayer3D = $Model/Head/Weapon/Penobscot_bow2/SpatialAudioPlayer3D

var Sound_Resource : Movement_sfx_resource = Globals.footsteps_sfx["Stone"]
@onready var Audio_Streamer := $SpatialAudioPlayer3D

var Collision_Exclusion : Array[RID] = []

# possible states
enum {IDLE, CHASING, ATTACKING, SEARCHING, DEAD, SHOOTING}
var state : int = IDLE
var seeing_player : bool = false
var player_last_spotet : Vector3
var is_shooting : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if player == null:
		player = get_node(player_path)
	animationPlayer.play("RESET")
	visionRay.target_position = Vector3(0,0,-vision_range)

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
			ATTACKING:
				print("Attacking")
				if state != SHOOTING:
					_shoot()
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
				if ((player.global_position - global_position).length()) < attack_range:
					if visionRay.is_colliding():
						if visionRay.get_collider().is_in_group("Player"):
							#print("Attacking")
							state = ATTACKING
							if !is_shooting:
								is_shooting = true
								_shoot()
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
					state = IDLE
					Audio_Streamer.stop()
			
		move_and_slide()

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
		head.get_node("StaticBody3D").queue_free()
		head.get_node("Weapon").queue_free()
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
		"""
		var coll_weapon_box = CollisionShape3D.new()
		var coll_weapon_shape = CapsuleShape3D.new()
		coll_weapon_shape.radius = 0.1
		coll_weapon_shape.height = 1
		coll_weapon_box.set_shape(coll_weapon_shape)
		pseudo_ragdoll_weapon.add_child(coll_weapon_box)
		"""
		
		#pseudo_ragdoll_weapon.add_child(coll_weapon)
		var weapon = $Model/Head/Weapon.duplicate()
		pseudo_ragdoll_weapon.add_child(weapon)
		pseudo_ragdoll_weapon.add_child($Model/Head/Weapon/Penobscot_bow2/Armature/Skeleton3D/Bow/StaticBody3D/CollisionShape3D.duplicate())
		#pseudo_ragdoll_weapon.add_child()
		#var pseudo_ragdoll_weapon = RigidBody3D.new()
		
		pseudo_ragdoll_weapon.global_position = $Model/Head/Weapon.global_position
		pseudo_ragdoll_weapon.rotation = $Model/Head/Weapon.rotation
		
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
	
func _shoot():
	if state != DEAD:
		state = SHOOTING
		animationPlayer_bow.play("Bow_shoot")
		audio_bow.stream = Globals.weapon_resources["Bow"].Chargeing_Sound
		audio_bow.play()
		await get_tree().create_timer(1.7).timeout
		audio_bow.stream = Globals.weapon_resources["Bow"].Shooting_Sound
		audio_bow.play()
		_Launc_Projectile(visionRay.get_collision_point())
		await animationPlayer_bow.animation_finished
		state = IDLE
		is_shooting = false
		

func _Launc_Projectile(Point: Vector3):
	var Direction = (Point - Shoot_Point.get_global_transform().origin).normalized()
	var Projectile = Globals.weapon_resources["Bow"].Projectile_to_Load.instantiate()

	var Projectile_RID = Projectile.get_rid()
	Collision_Exclusion.push_back(Projectile_RID)
	Projectile.tree_exited.connect(Remove_Exclusion.bind(Projectile.get_rid()))
	
	Shoot_Point.add_child(Projectile)
	Projectile.Damage = Globals.weapon_resources["Bow"].Damage
	Projectile.set_collision_layer_value(2,true)
	Projectile.set_collision_mask_value(2,true)
	Projectile.set_collision_layer_value(6,false)
	Projectile.set_collision_mask_value(6,false)
	Projectile.set_linear_velocity(Direction*Globals.weapon_resources["Bow"].Projectile_Velocity)

func Remove_Exclusion(projectile_rid : RID):
	Collision_Exclusion.erase(projectile_rid)
