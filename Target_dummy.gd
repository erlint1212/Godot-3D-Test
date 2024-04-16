extends RigidBody3D

var Health = 5

func Hit_Successful(Body, Damage, collison_point):
	print("Hit for: "+str(Damage)+", Health left: "+str(Health))
	Health -= Damage
	#Body.get_parent().remove_child(Body)
	#var saved_transform = Body.get_parent().global_transform
	if Body != null:
		Body.reparent(self)
	#Body.global_transform = saved_transform
	if Health <= 0:
		queue_free()

