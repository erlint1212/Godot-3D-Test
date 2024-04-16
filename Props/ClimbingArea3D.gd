extends Area3D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.state = body.CLIMBING



func _on_body_exited(body):
	if body.is_in_group("Player"):
		if body.state == body.CLIMBING:
			body.state = body.NORMAL
