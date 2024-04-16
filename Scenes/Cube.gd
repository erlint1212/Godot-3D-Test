extends RigidBody3D

@export var float_force = 1.4
# Water is denser than air
@export var water_drag = 0.05
@export var water_angular_drag = 0.1

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var water = $"../Water"

var probes;

var submerged = true
# Called when the node enters the scene tree for the first time.
func _ready():
	var ProbeContainer = Node3D.new()
	ProbeContainer.name = "ProbeContainer"
	
	var size = $MeshInstance3D.mesh.get_size()
	var length = size[0]/2
	var height_n = -size[1]/2
	var width = size[2]/2
	
	for height in [-height_n, 0, height_n]:
		var FR = Marker3D.new()
		FR.position = Vector3(length, height, width)
		ProbeContainer.add_child(FR)
		var FM = Marker3D.new()
		FM.position = Vector3(length, height, width)
		ProbeContainer.add_child(FM)
		var FL = Marker3D.new()
		FL.position = Vector3(length, height, width)
		ProbeContainer.add_child(FL)
		var BL = Marker3D.new()
		BL.position = Vector3(length, height, width)
		ProbeContainer.add_child(BL)
		var BM = Marker3D.new()
		BM.position = Vector3(length, height, width)
		ProbeContainer.add_child(BM)
		var BR = Marker3D.new()
		BR.position = Vector3(-length, height, width)
		ProbeContainer.add_child(BR)
		var MR = Marker3D.new()
		MR.position = Vector3(0, height, width)
		ProbeContainer.add_child(MR)
		var MM = Marker3D.new()
		MM.position = Vector3(0, height, 0)
		ProbeContainer.add_child(MM)
		var ML = Marker3D.new()
		ML.position = Vector3(0, height, -width)
		ProbeContainer.add_child(ML)
	
	self.add_child(ProbeContainer)
	#ProbeContainer.set_owner($".")
	
	probes = $ProbeContainer.get_children()
	#ProbeContainer.set_owner(get_tree().get_root())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	#if self.name == "Cuboid":
		#print(global_position.y)
	submerged = false
	for p in probes:
		var depth = water.get_height(p.global_position) - p.global_position.y
		if depth > 0:
			submerged = true
			# Applies pos force on coord from body
			#var meshBox = self.get_node("MeshInstance3D").mesh.size
			#var volume = meshBox[0]*meshBox[1]*meshBox[2]
			#apply_force(Vector3.UP * volume * 1024 * gravity * (1/2), p.global_position - global_position)
			apply_force(Vector3.UP * (float_force / 24) * gravity, p.global_position - global_position)
			
		
func _integrate_forces(state):
	#_integrate_forces instead of _physics_process because it's physics and physics may be run in anothe thread and run at different granularity.
	if submerged:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag
