extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSETIVITY = .005
const LERP_VAL = 0.15

var walking_sound = preload("res://Sounds/Walking/WalkingOnStone.wav")
var running_sound = preload("res://Sounds/Walking/RunningOnStone.wav")

@onready var Player_Mesh = $Armature
@onready var FootstepAudio = $FootstepAudio
@onready var spring_arm_pivot = $SpringArmPivot
@onready var spring_arm = $SpringArmPivot/SpringArm3D
@onready var anim_tree = $AnimationTree

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var state : int = 0

enum {IDLE, RUN, AIRBORNE}

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if event is InputEventMouseMotion:
		spring_arm_pivot.rotate_y(-event.relative.x * SENSETIVITY)
		spring_arm.rotate_x(-event.relative.y * SENSETIVITY)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)
		
		#Player_Mesh.rotation.y += -event.relative.x * SENSETIVITY# * SENSETIVITY# * SENSETIVITY
		#Player_Mesh.rotation.x = -event.relative.y * SENSETIVITY
		
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		if state != AIRBORNE:
			state = AIRBORNE
			FootstepAudio.stop()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("MoveLeft", "MoveRight", "MoveForward", "MoveBack")
	var direction = (spring_arm_pivot.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * SPEED, LERP_VAL)
		Player_Mesh.rotation.y = lerp_angle(Player_Mesh.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VAL)
		if state != RUN:
			#$AnimationPlayer.play("run")
			state = RUN
			#FootstepAudio.stream = running_sound
			FootstepAudio.play()
			
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)
		if state != IDLE:
			state = IDLE
			#$AnimationPlayer.play("idle")
			FootstepAudio.stop()
			
	anim_tree.set("parameters/BlendSpace1D/blend_position", velocity.length()/SPEED)
		
	move_and_slide()
