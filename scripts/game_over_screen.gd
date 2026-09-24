extends Control

# Change this path if your main scene has a different name
@export_file("*.tscn") var main_game_scene = "res://world.tscn"


func _on_restart_button_pressed() -> void:
	# Unpause first
	get_tree().paused = false

	# Make sure hit-stop hasn't left the game slowed/frozen
	Engine.time_scale = 1.0

	# Always return to the beginning of the game
	get_tree().change_scene_to_file(main_game_scene)
