extends CharacterBody3D

var player = null

const SPEED = 4.0

@export var player_path : NodePath

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var nav_agent = $NavigationAgent3D

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node(player_path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	print(global_position)
	
	if not is_on_floor():
		velocity.y -= gravity * delta * 10000
	
	#velocity = Vector3.ZERO
	#nav_agent.set_target_position(player.global_position)
	#var next_nav_point = nav_agent.get_next_path_position()
	#velocity = (next_nav_point - global_position).normalized() * SPEED
	
	move_and_slide()
