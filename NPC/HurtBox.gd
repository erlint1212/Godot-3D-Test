extends Area3D

@export var weapon_resource = Weapons_Resource
@export var exception_list = []
@export var Audio_Stream_Path : NodePath
@export var parent : Node3D

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
			if body.name == "Player" or body.name == "PlayerHitBox":
				print("Hit")
				var hit_length = parent.global_position.direction_to(parent.player.global_position).normalized() * Vector3(1.0 , 0.0, 1.0) * parent.HIT_PUSHBACK[0]
				hit_length.y = 0
				var hit_height = Vector3.UP *parent.HIT_PUSHBACK[1]
				body.get_owner().velocity += hit_length + hit_height


func _on_test_enemy_attack_animation_finished():
	exception_list = []
