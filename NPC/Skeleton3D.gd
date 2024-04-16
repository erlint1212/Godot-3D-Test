extends Skeleton3D

const MAX_HEAD_ROTATION : float = 180
const LERP_VAL : float = 0.5
const ROTATION_SPEED = 5


@onready var head = $Head
@onready var main_node = $"../.."
@onready var orignal_rotation = head.global_rotation

var looking : bool = false

enum {DEAD, ALIVE}

func _process(delta):
	if main_node.state == ALIVE:
		if main_node.distance < 5.0:
			head.look_at(main_node.player.global_position, Vector3.UP, true)
			head.global_rotation.y = clampf(head.global_rotation.y, -MAX_HEAD_ROTATION / 100, MAX_HEAD_ROTATION / 100)
			if !looking:
				looking_checker(false)
			# Source : https://kidscancode.org/godot_recipes/4.x/3d/rotate_interpolate/index.html
			#var target_position = main_node.player.transform.origin
			#var new_transform = head.transform.looking_at(target_position, Vector3.UP)
			#head.transform  = head.transform.interpolate_with(new_transform, ROTATION_SPEED * delta)
		else:
			if looking:
				looking_checker(true)
				head.global_rotation = lerp(head.global_rotation, orignal_rotation, LERP_VAL)

func looking_checker(opposite : bool) -> void:
	if opposite == true:
		looking = false
	elif opposite == false:
		looking = true
	else:
		push_warning("Looking is not a bool")
