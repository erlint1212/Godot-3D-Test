extends Node3D

signal is_interacting

@onready var Ray_Checker : RayCast3D = $"../Head/Camera3D/RayCast_Interactables"
@onready var Dialogue_Box : Polygon2D = $"../HUD/DialogueBox"
@onready var Dialogue_Text : RichTextLabel = $"../HUD/DialogueBox/RichTextLabel"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Interact"):
		#if !Dialogue_Box.is_visible():
		if Ray_Checker.is_colliding():
			var collider = Ray_Checker.get_collider()
			if collider.is_in_group("Interactable"):
				for element in collider.get_groups():
					match element:
						"Talkable":
							if collider.has_method("talking"):
								fade_out(0.9, 0.9)
								collider.talking()
							else:
								push_error("Object has Interactable but has no method talking")
						"Door":
							if collider.has_method("interact_door"):
								collider.interact_door()
						_:
							if collider.has_method("used"):
								collider.used()
		#else:
			#Dialogue_Box.hide()

func fade_out(In : float, Out : float) -> void:
	var tween = get_tree().create_tween()
	tween.tween_method(set_shader_value, In, Out, 0.4);

func set_shader_value(value: float) -> void:
	Dialogue_Box.material.set_shader_parameter("fade",value)
	Dialogue_Text.material.set_shader_parameter("fade",value)
