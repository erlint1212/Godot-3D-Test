extends Node2D


func _on_quit_pressed():
	get_tree().quit()


func _on_play_pressed():
	Globals.next_scene = "res://World.tscn"
	Globals.next_scene_name = "Test Map"
	get_tree().change_scene_to_packed(Globals.loading_screen)


func _on_play_forest_pressed():
	Globals.next_scene = "res://forest.tscn"
	Globals.next_scene_name = "Dark Forest"
	get_tree().change_scene_to_packed(Globals.loading_screen)


func _on_play_random_mountain_range_pressed():
	Globals.next_scene = "res://Scenes/world_generated.tscn"
	Globals.next_scene_name = "World Generation"
	get_tree().change_scene_to_packed(Globals.loading_screen)
