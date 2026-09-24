extends CanvasLayer

@onready var black_background = $BlackBackground
@onready var flash = $Flash
@onready var thunder_sound = $ThunderSound

var transition_started = false


func start_boss_transition():
	if transition_started:
		return

	transition_started = true
	
	var music = get_tree().current_scene.get_node_or_null("Music")

	if music:
		music.stop()

	# Cover game with black
	black_background.show()

	# Play thunder once for the whole sequence
	thunder_sound.play()

	# Brief darkness
	await get_tree().create_timer(0.3).timeout

	# First flash
	await lightning_flash()

	await get_tree().create_timer(0.35).timeout

	# Second flash
	await lightning_flash()

	await get_tree().create_timer(0.15).timeout

	# Quick flashes
	await lightning_flash(0.06)

	await get_tree().create_timer(0.08).timeout

	await lightning_flash(0.15)

	# Darkness before cutscene
	await get_tree().create_timer(0.5).timeout

	Engine.time_scale = 1.0

	get_tree().change_scene_to_file(
		"res://scenes/boss_cutscene.tscn"
	)


func lightning_flash(duration = 0.1):
	flash.show()

	await get_tree().create_timer(duration).timeout

	flash.hide()
