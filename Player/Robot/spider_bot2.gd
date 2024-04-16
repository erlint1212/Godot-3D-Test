extends CharacterBody3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var move_speed : float = 5.0
@export var turn_speed : float = 1.0
@export var ground_offset : float = 0.5

# The IK targets for the legs
@onready var fl_leg = $Armature/FrontLeftTarget
@onready var fr_leg = $Armature/FrontRightTarget

@onready var bl_leg = $Armature/BackLeftTarget
@onready var br_leg = $Armature/BackRightTarget

func _physics_process(delta):
	var plane1 = Plane(bl_leg.global_position, fl_leg.global_position, fr_leg.global_position)
	var plane2 = Plane(fr_leg.global_position, br_leg.global_position, bl_leg.global_position)
	var avg_normal = ((plane1.normal + plane2.normal)/2).normalized()
	
	var target_basis = _basis_from_normal(avg_normal)
	transform.basis = lerp(transform.basis, target_basis, move_speed * delta).orthonormalized()
	
	# Lift robot from ground
	var avg = (fl_leg.position + fr_leg.position + bl_leg.position + br_leg.position)/4
	var target_pos = avg + transform.basis.y * ground_offset
	var distance = transform.basis.y.dot(target_pos - position)
	position = lerp(position, position + transform.basis.y * distance, move_speed * delta)
	
	_handle_movement(delta)
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	
func _handle_movement(delta):
	var input_dir = Input.get_axis("MoveForward", "MoveBack")
	translate(Vector3(0,0,input_dir) * move_speed * delta)
	
	var input_dir_turn = Input.get_axis("MoveLeft", "MoveRight")
	rotate_object_local(Vector3.UP, input_dir_turn * turn_speed * delta)

func _basis_from_normal(normal : Vector3) -> Basis:
	var result = Basis()
	result.x = normal.cross(transform.basis.z)
	result.y = normal
	result.z = transform.basis.x.cross(normal)
	
	result = result.orthonormalized()
	result.x *= scale.x
	result.y *= scale.y
	result.z *= scale.z
	
	return result
	
	

