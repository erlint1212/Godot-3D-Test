extends Node3D

@export var player_path : NodePath
var AxeMan : PackedScene = preload("res://NPC/EnemyBugTest.tscn")
@onready var SummonMarker : Marker3D = $SummonMarker
@onready var player : CharacterBody3D = get_node(player_path)
@onready var click_sfx : AudioStreamPlayer3D = $SpatialAudioPlayer3D2
#@onready var click_sfx : AudioStreamWAV = preload("res://Sounds/Props/Flashlight Sound Effect sfx.wav")


func used(button : String):
	click_sfx.play()
	match button:
		"AxeMan":
			var mob = AxeMan.instantiate()
			mob.Health = 2
			mob.player = $"../Player"#player
			mob.global_position = SummonMarker.global_position
			print(mob.player)
			print(mob.player.global_position)
			#mob.initialize(SummonMarker.position, player.position)
			$"..".add_child(mob)
			
