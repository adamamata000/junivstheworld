extends CanvasLayer

@onready var black_background = $BlackBackground
@onready var flash = $Flash
@onready var thunder_sound = $ThunderSound

var transition_started = false


# =========================================================
# MAIN GAME -> BOSS CUTSCENE
# =========================================================

func start_boss_transition():
	if transition_started:
		return

	transition_started = true

	# Stop game music
	var music = get_tree().current_scene.get_node_or_null("Music")

	if music:
		music.stop()

	# Cover game with black
	black_background.show()

	# Thunder once
	thunder_sound.play()

	await get_tree().create_timer(0.3).timeout

	# First flash
	await lightning_flash()

	await get_tree().create_timer(0.35).timeout

	# Second flash
	await lightning_flash()

	await get_tree().create_timer(0.15).timeout

	# Quick flash
	await lightning_flash(0.06)

	await get_tree().create_timer(0.08).timeout

	# Final flash
	await lightning_flash(0.15)

	# Darkness
	await get_tree().create_timer(0.5).timeout

	Engine.time_scale = 1.0

	get_tree().change_scene_to_file(
		"res://scenes/boss_cutscene.tscn"
	)


# =========================================================
# BOSS CUTSCENE -> BOSS FIGHT
# =========================================================

func start_boss_fight_transition():
	if transition_started:
		return

	transition_started = true

	# Stop cutscene music if there is any
	var music = get_tree().current_scene.get_node_or_null("Music")

	if music:
		music.stop()

	# Thunder
	thunder_sound.play()

	# First flash
	flash.show()

	await get_tree().create_timer(0.12).timeout

	flash.hide()

	await get_tree().create_timer(0.15).timeout

	# Second stronger flash
	flash.show()

	await get_tree().create_timer(0.18).timeout

	# Go from white to black
	flash.hide()
	black_background.show()

	await get_tree().create_timer(0.5).timeout

	Engine.time_scale = 1.0

	get_tree().change_scene_to_file(
		"res://scenes/boss.tscn"
	)


# =========================================================
# LIGHTNING
# =========================================================

func lightning_flash(duration = 0.1):
	flash.show()

	await get_tree().create_timer(duration).timeout

	flash.hide()
