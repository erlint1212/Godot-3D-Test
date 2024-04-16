extends StaticBody3D

@export var damage_multiplier = 1.0
@export var command_node : Node

func Hit_Successful(Body, Damage, collison_point):
	#print("Headshot")
	if Body != null:
		Body.name = "Projectile_Mesh"
		Body.reparent($"..")
	print(get_parent().name)
	command_node.Hit_Calc(Body, Damage*damage_multiplier, collison_point)

