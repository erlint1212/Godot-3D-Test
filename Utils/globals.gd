extends Node

var loading_screen := preload("res://Scenes/loadingScreen.tscn")
var bow_resource : Weapons_Resource = preload("res://Weapons/Weapons_Resources/Bow_resource.tres")
var sword_resource : Weapons_Resource = preload("res://Weapons/Weapons_Resources/Sword_resource.tres")

var weapon_resources : Dictionary = {
	"Bow" : preload("res://Weapons/Weapons_Resources/Bow_resource.tres"),
	"Sword" : preload("res://Weapons/Weapons_Resources/Sword_resource.tres")
}

var footsteps_sfx : Dictionary = {
	"Carpet" : preload("res://Sounds/Footsteps/Resources/Carpet.tres"),
	"Metal" : preload("res://Sounds/Footsteps/Resources/Metal.tres"),
	"Sand" : preload("res://Sounds/Footsteps/Resources/Sand.tres"),
	"Stone" : preload("res://Sounds/Footsteps/Resources/Stone.tres"),
	"Wood" : preload("res://Sounds/Footsteps/Resources/Wood.tres")
}

var next_scene : String
var next_scene_name : String
