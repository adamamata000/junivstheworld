extends CanvasLayer

@export var starting_score = 0
@export var power_up_scene: PackedScene

var score = 0

@onready var score_label = $ScoreLabel

var power_up_spawned = false
var boss_cutscene_started = false


func _ready():
	score = starting_score

	# If we're already past these milestones,
	# don't trigger them again.
	if starting_score >= 20:
		power_up_spawned = true

	if starting_score >= 30:
		boss_cutscene_started = true

	update_score()


func add_score(amount):
	score += amount
	update_score()

	if score >= 20 and not power_up_spawned:
		spawn_power_up()

	if score >= 30 and not boss_cutscene_started:
		boss_cutscene_started = true
		start_boss_cutscene()


func update_score():
	score_label.text = str(score)


func spawn_power_up():
	power_up_spawned = true

	if power_up_scene == null:
		return

	var spawn_point = get_tree().current_scene.get_node_or_null(
		"PowerUpSpawn"
	)

	if spawn_point == null:
		return

	var power_up = power_up_scene.instantiate()

	get_tree().current_scene.add_child(power_up)

	power_up.global_position = spawn_point.global_position


func start_boss_cutscene():
	var transition_ui = get_tree().current_scene.get_node_or_null(
		"TransitionUI"
	)

	if transition_ui == null:
		print("ERROR: TransitionUI not found!")
		return

	transition_ui.start_boss_transition()
