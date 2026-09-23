extends CanvasLayer

var score = 0

@export var power_up_scene: PackedScene

@onready var score_label = $ScoreLabel

var power_up_spawned = false


func _ready():
	update_score()


func add_score(amount):
	score += amount
	update_score()

	# Spawn the power-up once when we reach 20
	if score >= 20 and not power_up_spawned:
		spawn_power_up()


func update_score():
	score_label.text = str(score)


func spawn_power_up():
	power_up_spawned = true

	var power_up = power_up_scene.instantiate()

	var spawn_point = get_tree().current_scene.get_node("PowerUpSpawn")

	get_tree().current_scene.add_child(power_up)

	power_up.global_position = spawn_point.global_position
