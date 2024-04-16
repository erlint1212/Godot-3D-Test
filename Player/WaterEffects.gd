extends Node3D

# Water Speed Velocity formula
# c = 1404.3 + 4.7 T - 0.04 T2
# T : Temprature
# T2 : 

# Archimedes Principle
#Force from bouyancy: F b = ρ V g
# F : Force : N
# ρ : Water denisty : kg/m^-3
# V : displaced water : m^3
# g : gravity : m/s^-2

#var WaterDisplacementMax = 0.078

@export var player_path : NodePath

var extra_weights = 1.0
const Player_height = 1.7
var human_density = 1010
var current_pressure : float
var bouyancy_force : float
var current_volume : float = 0.078

@onready var player = get_node(player_path)

# V = (mass / Pressure) * gravity * depth
func bouyancy(depth):
	current_pressure = pressure()
	#current_volume = Volume(current_pressure)
	#print("Volume: ", roundf(current_volume))
	bouyancy_force = current_volume * player.gravity * player.water.density
	if 0.0 >= depth and depth > -Player_height/2.0:
		bouyancy_force = (current_volume/2)*(1.0 + depth/(Player_height)) * player.gravity * player.water.density
	elif Player_height/2.0 > depth and depth > 0.0:
		bouyancy_force = (current_volume/2 + (current_volume/2)*(depth/(Player_height))) * player.gravity * player.water.density
	return bouyancy_force

func Volume(pressure : float) -> float:
	return (player.MASS/pressure) * player.gravity * player.depth

# Hydrostatic preesure / gauge pressure
func pressure()->float:
	return player.water.density * player.gravity * player.depth
