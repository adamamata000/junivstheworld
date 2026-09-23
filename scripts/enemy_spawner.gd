extends Node

# All enemy types that this spawner can create
@export var enemy_scenes: Array[PackedScene]

# Starting spawn timing
@export var starting_minimum_spawn_time = 3.0
@export var starting_maximum_spawn_time = 6.0

# Hardest spawn timing
@export var minimum_spawn_limit = 0.8
@export var maximum_spawn_limit = 1.5

# Difficulty
@export var difficulty_increase_every = 5.0
@export var spawn_time_reduction = 0.3

# Current spawn timing
var current_minimum_spawn_time
var current_maximum_spawn_time

# Difficulty timer
var difficulty_timer = 0.0

# Nodes
@onready var spawn_timer = $SpawnTimer
@onready var left_spawn = $"../LeftSpawn"
@onready var right_spawn = $"../RightSpawn"


func _ready():
	current_minimum_spawn_time = starting_minimum_spawn_time
	current_maximum_spawn_time = starting_maximum_spawn_time

	start_spawn_timer()


func _process(delta):
	difficulty_timer += delta

	# Increase difficulty every X seconds
	if difficulty_timer >= difficulty_increase_every:
		difficulty_timer = 0.0
		increase_difficulty()


func increase_difficulty():
	# Reduce minimum spawn time
	current_minimum_spawn_time = max(
		current_minimum_spawn_time - spawn_time_reduction,
		minimum_spawn_limit
	)

	# Reduce maximum spawn time
	current_maximum_spawn_time = max(
		current_maximum_spawn_time - spawn_time_reduction,
		maximum_spawn_limit
	)

	print(
		"Difficulty increased! Spawn time: ",
		current_minimum_spawn_time,
		" - ",
		current_maximum_spawn_time
	)


func start_spawn_timer():
	spawn_timer.wait_time = randf_range(
		current_minimum_spawn_time,
		current_maximum_spawn_time
	)

	spawn_timer.start()


func spawn_enemy():
	# Don't spawn anything if the list is empty
	if enemy_scenes.is_empty():
		return

	# Pick a random enemy type
	var random_enemy_scene = enemy_scenes.pick_random()

	# Create that enemy
	var enemy = random_enemy_scene.instantiate()

	# Randomly choose left or right
	var spawn_point

	if randi() % 2 == 0:
		spawn_point = left_spawn
	else:
		spawn_point = right_spawn

	# Add enemy to the world
	get_parent().add_child(enemy)

	# Put enemy at chosen spawn point
	enemy.global_position = spawn_point.global_position

	# Start waiting for the next enemy
	start_spawn_timer()


func _on_spawn_timer_timeout():
	spawn_enemy()
