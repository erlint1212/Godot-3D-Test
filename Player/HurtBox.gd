extends Area3D

@export var weapon_resource = Weapons_Resource
@export var exception_list = []
@export var Audio_Stream_Path : NodePath

func _on_body_entered(body):
	print(exception_list)
	if body.name not in exception_list:
		if body.has_method("Hit_Successful"):
			get_node(Audio_Stream_Path).stream = weapon_resource.Hit_Sound
			get_node(Audio_Stream_Path).play()
			exception_list.append(body.name)
			var damage = weapon_resource.Damage
			body.Hit_Successful(null, damage, null)
			#get_node("Weapon_Manager").hit()



func _on_weapons_manager_hit_animation_finished():
	exception_list = []
