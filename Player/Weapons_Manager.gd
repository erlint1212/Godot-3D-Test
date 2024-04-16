extends Node3D

signal Weapon_Changed
signal Update_Ammo
signal Update_Weapon_Stack
signal Released_Shot
signal hit_animation_finished

@export var Meshes_With_Shaders : Array[MeshInstance3D]
@export var _weapon_resources: Array[Weapons_Resource]
@export var Start_Weapon: Array[String]


var Released_Shot_recent = false

var Current_Weapon = null
var Weapon_Stack = [] # Array of all weapons currently available to us ingame
var Weapon_Indicator = 0
var Next_Weapon : String
var Weapon_List = {}
var Weapon_equipped = true

# Bow bandaids Find better solutions
var bow_base_AT = 2.5
var bow_AS_mult = 1.9

@onready var camera = $".."
@onready var Animation_Player =  $FPS_Rig/AnimationPlayer
@onready var bow = $FPS_Rig/Penobscot_bow2/AnimationPlayer
@onready var Shoot_Point = %Shoot_Point
@onready var player = $"../../.."
#@onready var sword_hit_sound


# Sounds
@onready var AudioSteamPlayerR = $WeaponSounds


# Filler because Type skips 3 ????
enum {NULL, HITSCAN, PROJECTILE, FILLER, MELEE}

var Collision_Exclusion = []

func _ready():
	Initialize(Start_Weapon) # Enter the state machine

func _input(event):
	if player.state not in [player.PAUSED, player.DEAD]:
		if Input.is_action_just_pressed("ToggleReadyWeapon") and Weapon_equipped == false:
			Weapon_equipped = true
			
			if Current_Weapon.Current_Ammo <= 0 and Current_Weapon.Weapon_Name == "Bow":
				$FPS_Rig/Penobscot_bow2/Arrow2.hide()
			elif Current_Weapon.Weapon_Name == "Bow":
				$FPS_Rig/Penobscot_bow2/Arrow2.show()
				
			Animation_Player.play(Current_Weapon.Activate_Anim)
			if Current_Weapon.Draw_sound:
				AudioSteamPlayerR.stream = Current_Weapon.Draw_sound
				AudioSteamPlayerR.play()
			$"../../../HUD/Main_Sight".show()
			
		elif Input.is_action_just_pressed("ToggleReadyWeapon") and Weapon_equipped == true:
			Weapon_equipped = false
			Animation_Player.play_backwards(Current_Weapon.Activate_Anim)
			$"../../../HUD/Main_Sight".hide()
			
		
		if Input.is_action_just_released("ChangeWeaponUp"):
			Weapon_Indicator = min(Weapon_Indicator+1, Weapon_Stack.size()-1)
			print("Change ", Weapon_Indicator, Weapon_Stack[Weapon_Indicator])
			exit(Weapon_Stack[Weapon_Indicator])
		elif Input.is_action_just_released("ChangeWeaponDown"):
			Weapon_Indicator = max(Weapon_Indicator-1, 0)
			print("Change ", Weapon_Indicator, Weapon_Stack[Weapon_Indicator])
			exit(Weapon_Stack[Weapon_Indicator])
			
		if Input.is_action_just_pressed("Select_1"):
			Weapon_Indicator = 0
			print("Change ", Weapon_Indicator, Weapon_Stack[Weapon_Indicator])
			exit(Weapon_Stack[Weapon_Indicator])
		elif Input.is_action_just_pressed("Select_2"):
			Weapon_Indicator = 1
			print("Change ", Weapon_Indicator, Weapon_Stack[Weapon_Indicator])
			exit(Weapon_Stack[Weapon_Indicator])

		if Input.is_action_just_pressed("Shoot") and Weapon_equipped == true:
			shoot()
			await get_tree().create_timer((bow_base_AT*0.65)/bow_AS_mult).timeout
			Released_Shot.emit()
			
		
		if Input.is_action_just_released("Shoot"):
			Released_Shot.emit()
			Released_Shot_recent = true
			#await get_tree().create_timer(0.1).timeout
			#Released_Shot_recent = false
		
		if event.is_action_pressed("Reload") and Weapon_equipped == true:
			reload()

func Initialize(_start_weapons : Array):
	# Creating a dictionary to refer to our waapons
	for weapon in _weapon_resources:
		Weapon_List[weapon.Weapon_Name] = weapon
	
	for i in _start_weapons:
		Weapon_Stack.push_back(i) # Add our start weapon
	
	Current_Weapon = Weapon_List[Weapon_Stack[0]]
	emit_signal("Update_Weapon_Stack", Weapon_Stack)
	enter()
	
func enter():
	# Call when first "entering" into a weapon
	if Weapon_equipped:
		Animation_Player.queue(Current_Weapon.Activate_Anim)
		if Current_Weapon.Draw_sound:
			await get_tree().create_timer(Animation_Player.current_animation_length).timeout
			AudioSteamPlayerR.stream = Current_Weapon.Draw_sound
			AudioSteamPlayerR.play()
			
	emit_signal("Weapon_Changed", Current_Weapon.Weapon_Name)
	emit_signal("Update_Ammo", [Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
	
func exit(_next_weapon : String) -> void:
	# Before change weapons, call exit
	if _next_weapon != Current_Weapon.Weapon_Name:
		if Animation_Player.current_animation != Current_Weapon.Shoot_Anim:
			#if Animation_Player.get_current_animation() != Current_Weapon.Deactivate_Anim:
			if Weapon_equipped:
				Animation_Player.play_backwards(Current_Weapon.Activate_Anim)
			Next_Weapon = _next_weapon
			Change_Weapon(_next_weapon)
			
func Change_Weapon(weapon_name : String) -> void:
	print("Change_Weapon ",weapon_name)
	Current_Weapon = Weapon_List[weapon_name]
	Next_Weapon = ""
	enter()

func _on_animation_player_animation_finished(anim_name):
	#if anim_name == Current_Weapon.Deactivate_Anim:
		#Change_Weapon(Next_Weapon)
	
	if anim_name == Current_Weapon.Shoot_Anim and Current_Weapon.Auto_Fire == true:
		if Input.is_action_pressed("Shoot"):
			shoot()

func shoot():
	if Current_Weapon.Type != MELEE:
		if Current_Weapon.Current_Ammo > 0:
			if !Animation_Player.is_playing(): # Enforce the firerate set by the animation
				if Current_Weapon.Weapon_Name == "Bow":
					bow.speed_scale = bow_AS_mult
					bow.play("Bow_shoot")
					
					if Released_Shot_recent == true:
						Released_Shot_recent = false
					
					#Animation_Player.play(Current_Weapon.Shoot_Anim)
					if Current_Weapon.Chargeing_Sound != null:
						AudioSteamPlayerR.stream = Current_Weapon.Chargeing_Sound
						AudioSteamPlayerR.play()
					await Released_Shot #get_tree().create_timer((bow_base_AT*0.65)/bow_AS_mult).timeout
					print(Released_Shot_recent)
					"""
					if Released_Shot_recent:
						bow.pause()
						bow.play_backwards("Bow_shoot")
						Released_Shot_recent = false
					else:
					"""
						# Await the release of the string
					bow.pause()
					await Released_Shot
					bow.play("Bow_shoot")
					Released_Shot_recent = false
					
					Current_Weapon.Current_Ammo -= 1
					emit_signal("Update_Ammo", [Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
					bow.speed_scale = 1
					
					var Camera_Collision = Get_Camera_Collision()
					
					match Current_Weapon.Type:
						NULL:
							print("No weapon type selected")
						HITSCAN:
							print("Not implemented")
						PROJECTILE:
							Launc_Projectile(Camera_Collision)
							AudioSteamPlayerR.stream = Current_Weapon.Shooting_Sound
							AudioSteamPlayerR.play()
	elif Current_Weapon.Type == MELEE:
		melee()
	
func melee():
	Animation_Player.play(Current_Weapon.Shoot_Anim)
	await Animation_Player.animation_finished
	emit_signal("hit_animation_finished")

func reload():
	if Current_Weapon.Current_Ammo == Current_Weapon.Magazine:
		return
	elif !Animation_Player.is_playing():
		if Current_Weapon.Reserve_Ammo > 0:
			#Action_Player.play(Current_Weapon.Reload_Anim)
			var Reload_Amount = min(Current_Weapon.Magazine - Current_Weapon.Current_Ammo,
			 Current_Weapon.Magazine, Current_Weapon.Reserve_Ammo)
			Current_Weapon.Current_Ammo += Reload_Amount
			Current_Weapon.Reserve_Ammo -= Reload_Amount
			
			emit_signal("Update_Ammo", [Current_Weapon.Current_Ammo, Current_Weapon.Reserve_Ammo])
			Animation_Player.play(Current_Weapon.Reload_Anim)
		else:
			print("Out of Ammo")
			#Animation_Player.play(Current_Weapon.Out_Of_Ammo_Anim)

func Get_Camera_Collision()->Vector3:
	var camera = get_viewport().get_camera_3d()
	var viewport = get_viewport().get_size()
	
	var Ray_Origin = camera.project_ray_origin(viewport/2)
	var Ray_End = Ray_Origin + camera.project_ray_normal(viewport/2)*Current_Weapon.Weapon_Range
	
	var New_Intersection = PhysicsRayQueryParameters3D.create(Ray_Origin,Ray_End)
	New_Intersection.set_exclude(Collision_Exclusion) # Makes it so shot projectiles don't change trajectory based on new missiles.
	var Intersection = get_world_3d().direct_space_state.intersect_ray(New_Intersection)
	
	if not Intersection.is_empty():
		var Col_Point = Intersection.position
		return Col_Point
	else:
		return Ray_End

func Launc_Projectile(Point: Vector3):
	var Direction = (Point - Shoot_Point.get_global_transform().origin).normalized()
	var Projectile = Current_Weapon.Projectile_to_Load.instantiate()

	var Projectile_RID = Projectile.get_rid()
	Collision_Exclusion.push_back(Projectile_RID)
	Projectile.tree_exited.connect(Remove_Exclusion.bind(Projectile.get_rid()))
	
	Shoot_Point.add_child(Projectile)
	Projectile.Damage = Current_Weapon.Damage
	Projectile.set_linear_velocity(Direction*Current_Weapon.Projectile_Velocity)
	
func Remove_Exclusion(projectile_rid):
	Collision_Exclusion.erase(projectile_rid)
	

func _on_player_fov_changed(target : Array):
	for n in Meshes_With_Shaders:
		if n != null:
			for i in range(n.mesh.get_surface_count()):
				var mat : Material = n.get_active_material(i)
				if mat is ShaderMaterial:
					var tween := create_tween()
					tween.tween_method(func(t): mat.set_shader_parameter("viewmodel_fov", t), camera.fov, target[0], target[1] * 8.0)

