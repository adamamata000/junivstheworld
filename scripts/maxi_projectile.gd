extends Area2D

@export var flight_time = 1.0
@export var arc_height = 250.0
@export var damage = 10
@export var rotation_speed = 4.0

# Perspective effect
@export var starting_scale = 0.45
@export var ending_scale = 1.0

var velocity = Vector2.ZERO
var projectile_gravity = 0.0
var has_been_thrown = false

var flight_timer = 0.0


func _ready():
	body_entered.connect(_on_body_entered)

	# Start small because projectile is "far away"
	scale = Vector2.ONE * starting_scale


func aim_at(target_position: Vector2):
	var displacement = target_position - global_position

	# Horizontal movement
	velocity.x = displacement.x / flight_time

	# Arc
	projectile_gravity = (
		8.0 * arc_height
		/ (flight_time * flight_time)
	)

	velocity.y = (
		displacement.y / flight_time
		- 0.5 * projectile_gravity * flight_time
	)

	has_been_thrown = true


func _physics_process(delta):
	if not has_been_thrown:
		return

	flight_timer += delta

	# Gravity
	velocity.y += projectile_gravity * delta

	# Movement
	global_position += velocity * delta

	# Spin
	rotation += rotation_speed * delta

	# -----------------------
	# FAKE 3D PERSPECTIVE
	# -----------------------

	var progress = clamp(
		flight_timer / flight_time,
		0.0,
		1.0
	)

	var current_scale = lerp(
		starting_scale,
		ending_scale,
		progress
	)

	scale = Vector2.ONE * current_scale

	# Cleanup
	if global_position.x < -500:
		queue_free()

	if global_position.x > 1800:
		queue_free()

	if global_position.y > 1200:
		queue_free()


func _on_body_entered(body):
	if body.name == "Juni":
		body.take_damage(damage)
		queue_free()
