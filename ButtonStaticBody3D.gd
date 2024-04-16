extends StaticBody3D

@export var button_id : String = "undefined"
@export var ButtonSystem : NodePath
@onready var Button_System_Node = get_node(ButtonSystem)

func used():
	Button_System_Node.used(button_id)
