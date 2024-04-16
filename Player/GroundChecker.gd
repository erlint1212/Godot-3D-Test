extends RayCast3D

signal surface_changed

@onready var player : CharacterBody3D = $".."
@onready var wood_resource : Movement_sfx_resource = preload("res://Sounds/Footsteps/Resources/Wood.tres")
@onready var stone_resource : Movement_sfx_resource = preload("res://Sounds/Footsteps/Resources/Stone.tres")
@onready var carpet_resource : Movement_sfx_resource = preload("res://Sounds/Footsteps/Resources/Carpet.tres")
@onready var metal_resource : Movement_sfx_resource = preload("res://Sounds/Footsteps/Resources/Metal.tres")
@onready var sand_resource : Movement_sfx_resource = preload("res://Sounds/Footsteps/Resources/Sand.tres")
@onready var water_resource : Movement_sfx_resource = preload("res://Sounds/Footsteps/Resources/Water.tres")
var last_surface : int
var last_resource : Movement_sfx_resource
var last_group : StringName

func surface_sfx() -> Movement_sfx_resource:
	print("Surface SFX called")
	if !is_colliding():
		return stone_resource
	var collider_group : Array[StringName] = get_collider().get_groups()
	#print(collider_group)
	if collider_group.size() != 1:
		return stone_resource
	match [collider_group[0]]:
		["wood_ground"]:
			return wood_resource
		["stone_ground"]:
			return stone_resource
		["carpet_ground"]:
			return carpet_resource
		["metal_resource"]:
			return metal_resource
		["sand_ground"]:
			return sand_resource
		["water_ground"]:
			return water_resource
		_:
			return stone_resource

func _process(delta):
	if is_colliding():
		#if get_collider().get_parent().get_class() in [MeshInstance3D, CSGShape3D]:
		var current_surface : int = get_collider().get_instance_id()
		#var collider_group : Array[StringName] = get_collider().get_groups()
		if last_surface != current_surface or !last_surface:
			#if last_group not in collider_group:
			last_surface = current_surface
			emit_signal("surface_changed", surface_sfx())
			print("surface_changed")
