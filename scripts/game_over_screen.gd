extends Control


func _on_restart_button_pressed() -> void:
	print("RESTART BUTTON PRESSED")

	get_tree().paused = false
	Engine.time_scale = 1.0

	get_tree().reload_current_scene()
