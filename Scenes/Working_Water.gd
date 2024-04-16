@tool

extends Node3D

@export var noise = FastNoiseLite.new()
@export var object_scalar = 60;
@export var plane_size = Vector2(400,400)
@export var folliage = false
@export var trees = false
@export var plane_height = 0

var ZERO_TRANSFORM = Transform3D.IDENTITY.scaled(Vector3.ZERO)

func _ready():
	generate_plane()

func generate_plane():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = plane_size #Vector2(400,400)
	plane_mesh.subdivide_depth = 200
	plane_mesh.subdivide_width = 200

	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh, 0)

	var array_plane = surface_tool.commit()

	var data_tool = MeshDataTool.new()

	data_tool.create_from_surface(array_plane, 0)

	for i in range(data_tool.get_vertex_count()):
		var vertex = data_tool.get_vertex(i)
		vertex.y = noise.get_noise_3d(vertex.x, vertex.y, vertex.z) * object_scalar
		
		data_tool.set_vertex(i, vertex)

	array_plane.clear_surfaces()

	data_tool.commit_to_surface(array_plane)
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.create_from(array_plane, 0)
	surface_tool.generate_normals()

	var mesh_instance = MeshInstance3D.new()

	mesh_instance.mesh = surface_tool.commit()
	mesh_instance.position.y = plane_height
	mesh_instance.create_trimesh_collision()
	add_child(mesh_instance)
	mesh_instance.set_surface_override_material(0, load("res://Textures/Sand/sand_material_3d.tres"))
	
	if folliage and get_node_or_null("Folliage_MM3D"):
		position_objs($Folliage_MM3D, false)
	elif get_node_or_null("Folliage_MM3D"):
		for i in $Folliage_MM3D.multimesh.instance_count:
			$Folliage_MM3D.multimesh.set_instance_transform(i, ZERO_TRANSFORM)
	if trees and get_node_or_null("Tree_MM3D"):
		position_objs($Tree_MM3D, true)
	elif get_node_or_null("Tree_MM3D"):
		for i in $Tree_MM3D.multimesh.instance_count:
			$Tree_MM3D.multimesh.set_instance_transform(i, ZERO_TRANSFORM)


func position_objs(obj : MultiMeshInstance3D, collide : bool):
	randomize()
	for i in obj.multimesh.instance_count:
		var x_loc = randf_range(-plane_size[0]/2, plane_size[0]/2)
		var y_loc = randf_range(-plane_size[1]/2, plane_size[1]/2)
		var v = Vector3(x_loc, 
						0.0, 
						y_loc)
		v.y = noise.get_noise_3d(v.x, v.y, v.z) * object_scalar #set_noise_position(v)
		obj.multimesh.set_instance_transform(i, Transform3D(Basis.IDENTITY, v))
		if collide:
			add_collision(v)

func add_collision(coord : Vector3):
	var staticB = StaticBody3D.new()
	var shape = CylinderShape3D.new()
	shape.set_height(2.0)
	shape.set_radius(0.5)
	
	var collision = CollisionShape3D.new()
	collision.set_shape(shape)
	
	coord.y += 1
	
	staticB.set_position(coord)
	staticB.add_child(collision)
	add_child(staticB)

func water_temprature():
	pass
	#var T = 
