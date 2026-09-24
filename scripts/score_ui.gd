extends CanvasLayer

var score = 0

@export var power_up_scene: PackedScene

@onready var score_label = $ScoreLabel

var power_up_spawned = false

var boss_cutscene_started = false

func _ready():
	update_score()


func add_score(amount):
	score += amount
	update_score()

	# Power-up at 20
	if score >= 20 and not power_up_spawned:
		spawn_power_up()

	# Cutscene at 30
	if score >= 30 and not boss_cutscene_started:
		boss_cutscene_started = true
		start_boss_cutscene()
		
func start_boss_cutscene():
	var transition_ui = get_tree().current_scene.get_node("TransitionUI")
	transition_ui.start_boss_transition()


func update_score():
	score_label.text = str(score)


func spawn_power_up():
	power_up_spawned = true

	var power_up = power_up_scene.instantiate()

	var spawn_point = get_tree().current_scene.get_node("PowerUpSpawn")

	get_tree().current_scene.add_child(power_up)

	power_up.global_position = spawn_point.global_position
