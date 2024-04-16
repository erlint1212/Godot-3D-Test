extends CanvasLayer

@onready var player_node : CharacterBody3D = $".."

@onready var CurrentWeaponLabel : Label = $VBoxContainer/HBoxContainer/CurrentWeapon
@onready var CurrentAmmoLabel : Label = $VBoxContainer/HBoxContainer2/CurrentAmmoCount
@onready var CurrentWeaponStack : Label = $VBoxContainer/HBoxContainer3/WeaponStack
@onready var CurrentDepth : Label = $VBoxContainer/HBoxContainer4/Depth
@onready var CurrentPressure : Label = $VBoxContainer/HBoxContainer5/Pressure
@onready var CurrentHumanLimit : Label = $VBoxContainer/HBoxContainer6/HumanLimit
@onready var CurrentFPS : Label = $VBoxContainer2/HBoxContainer/FPS
@onready var CurrentHealth : Label = $VBoxContainer/HBoxContainer7/Health

@onready var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var SaltWater_density = 1024 #kg/m^3

func _process(_delta) -> void:
	CurrentFPS.set_text(str(Engine.get_frames_per_second()))

func _on_weapons_manager_update_ammo(Ammo):
	#Ammo[0] : Current_Ammo , Ammo[1] : Reserve Ammo
	CurrentAmmoLabel.set_text(str(Ammo[0])+" / "+str(Ammo[1]))

func _on_weapons_manager_update_weapon_stack(Weapon_Stack):
	CurrentWeaponStack.set_text("")
	for i in Weapon_Stack:
		CurrentWeaponStack.text += "\n"+i

func _on_weapons_manager_weapon_changed(Weapon_Name):
	CurrentWeaponLabel.set_text(Weapon_Name)

func _on_player_update_depth(depth):
	CurrentDepth.set_text(str(-roundf(depth))+ "m")
	CurrentPressure.set_text(str(roundf(snapped((1020*depth*gravity + 101325)*pow(10, -5),0.1))) + " bar")
	CurrentHumanLimit.set_text(str(snapped(roundf((1020*depth*gravity + 101325)*pow(10, -5)/1.01), 0.1)) + "%")


func _on_player_update_health():
	CurrentHealth.set_text(str(player_node.health) + " / " + str(player_node.max_health))
