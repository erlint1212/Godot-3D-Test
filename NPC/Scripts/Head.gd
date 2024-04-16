extends Node3D

@export var damage_multiplier = 1.0

func Hit_Successful(Body, Damage):
	Body.reparent($"..")
	print(get_parent().name)
	$"../../..".Hit_Calc(Body, Damage*damage_multiplier)
