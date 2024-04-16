extends RigidBody3D

var Damage : int = 0
# Inefficent, have to call for every arrow instead of once
@onready var HitSound = preload("res://Sounds/ArrowHit.wav")
@onready var FallSound = preload("res://Sounds/ArrowFalling.wav")
@onready var Wooden_Hole = preload("res://Textures/Holes/wood_pen_decal.tscn")
var firstBody = true
var collidedList = []

func _process(_delta):
	if $HoleMaker.is_colliding():
		if $HoleMaker.get_collider():
			if $HoleMaker.get_collider().is_in_group("Light_Penetrable"):
				print("Colliding, RID: ",str($HoleMaker.get_collider_rid()))
				#$HoleMaker.get_collider().Hit($HoleMaker)
				create_bullethole($HoleMaker)
				$HoleMaker.add_exception_rid($HoleMaker.get_collider_rid())
		
func create_bullethole(r):
	# Source: https://godotforums.org/d/34389-bullet-hole-decals-not-rotating-properly-when-surface-is-levelvertically-flat/4
	var b = Wooden_Hole.instantiate()
	r.get_collider().add_child(b)
	b.global_transform.origin = r.get_collision_point()
	if r.get_collision_normal() == Vector3(0,1,0):
		b.look_at(r.get_collision_point() + r.get_collision_normal(), Vector3.RIGHT)
	elif r.get_collision_normal() == Vector3(0,-1,0):
		b.look_at(r.get_collision_point() + r.get_collision_normal(), Vector3.RIGHT)
	else:
		b.look_at(r.get_collision_point() + r.get_collision_normal())

func _on_body_entered(body):
	#print(body.name)
	
	if not body.is_in_group("Light_Penetrable"):
		if body.has_method("Hit_Successful"): #body.is_in_group("Target") and
			var collison_point = null
			if $HoleMaker.is_colliding():
				collison_point = $HoleMaker.get_collision_point()
			
			#print(body.name)
			#if collison_point == null:
				#collison_point = global_position
			
			if $Arrow_Shoot:
				$Arrow_Shoot.position += Vector3.FORWARD * rotation
			
			body.Hit_Successful($Arrow_Shoot, Damage, collison_point)
			#self.set_linear_velocity(Vector3(0,0,0))
			# Add method to objects weather or not the arrow should get stuck.
			$CollisionShape3D.set_deferred("disabled", true)
			# No need to hide mesh, as it is reparented in Hit_Successful
			$HitPlayer3D.stream = HitSound
			$HitPlayer3D.play()
			await $HitPlayer3D.finished
			queue_free()
		else:
			pass#queue_free()
		if firstBody == true:
			# Sound origin is arrow not object, no issue if stuck, big issue if falling
			$HitPlayer3D.stream = HitSound
			$HitPlayer3D.play()
			$HoleMaker.clear_exceptions()
			firstBody = false
		else:
			$FallPlayer3D.stream = FallSound
			$FallPlayer3D.play()
	else:
		if body.is_in_group("Light_Penetrable") and body.has_method("Hit"):
			pass
			#body.Hit(self.position)
		
func _on_timer_timeout():
	queue_free()
	
