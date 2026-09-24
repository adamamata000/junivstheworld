extends Area2D

@export var flight_time = 1.0
@export var arc_height = 250.0
@export var damage = 50

# Perspective
@export var starting_scale = 0.45
@export var ending_scale = 1.0

# Fire trail
@export var trail_interval = 0.03
@export var trail_min_distance = 15.0
@export var trail_max_distance = 30.0

var velocity = Vector2.ZERO
var projectile_gravity = 0.0
var has_been_thrown = false

var flight_timer = 0.0
var trail_timer = 0.0

@onready var fire_sound = $FireSound


func _ready():
	body_entered.connect(_on_body_entered)

	scale = Vector2.ONE * starting_scale
	rotation = 0.0
	z_index = 51

	fire_sound.play()

func aim_at(target_position: Vector2):
	var displacement = target_position - global_position

	# Horizontal movement
	velocity.x = displacement.x / flight_time

	# Calculate gravity for the arc
	projectile_gravity = (
		8.0 * arc_height
		/ (flight_time * flight_time)
	)

	# Initial vertical velocity
	velocity.y = (
		displacement.y / flight_time
		- 0.5 * projectile_gravity * flight_time
	)

	has_been_thrown = true


func _physics_process(delta):
	if not has_been_thrown:
		return

	flight_timer += delta
	trail_timer += delta

	# Apply gravity
	velocity.y += projectile_gravity * delta

	# Move projectile
	global_position += velocity * delta

	# Keep fireball completely upright
	rotation = 0.0

	# Create fire trail
	if trail_timer >= trail_interval:
		trail_timer = 0.0
		create_fire_trail()

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

	# -----------------------
	# CLEANUP
	# -----------------------

	if global_position.x < -500:
		queue_free()

	if global_position.x > 1800:
		queue_free()

	if global_position.y > 1200:
		queue_free()


func create_fire_trail():
	var ember = Polygon2D.new()

	# Circular-ish pixel ember
	ember.polygon = PackedVector2Array([
		Vector2(-8, -4),
		Vector2(-4, -8),
		Vector2(4, -8),
		Vector2(8, -4),
		Vector2(8, 4),
		Vector2(4, 8),
		Vector2(-4, 8),
		Vector2(-8, 4)
	])

	# Bright orange
	ember.color = Color(
		1.0,
		0.35,
		0.02,
		1.0
	)

	# Add ember to the scene itself so it doesn't
	# move along with the projectile
	get_tree().current_scene.add_child(ember)

	# Work out which direction the fireball is travelling
	var travel_direction = velocity.normalized()

	# Put particle slightly BEHIND the fireball
	var trail_distance = randf_range(
		trail_min_distance,
		trail_max_distance
	)

	ember.global_position = (
		global_position
		- travel_direction * trail_distance
	)

	# Add slight randomness so the trail isn't perfectly straight
	ember.global_position += Vector2(
		randf_range(-5.0, 5.0),
		randf_range(-5.0, 5.0)
	)

	# Trail = 50
	# Fireball = 51
	# So trail appears behind fireball but above background
	ember.z_index = 50

	# Random particle size
	var particle_size = randf_range(
		0.7,
		1.4
	)

	ember.scale = Vector2.ONE * particle_size

	# -----------------------
	# ANIMATE EMBER
	# -----------------------

	var tween = ember.create_tween()

	tween.set_parallel(true)

	# Fade away
	tween.tween_property(
		ember,
		"modulate:a",
		0.0,
		0.45
	)

	# Shrink away
	tween.tween_property(
		ember,
		"scale",
		Vector2.ZERO,
		0.45
	)

	# Drift slightly upward
	tween.tween_property(
		ember,
		"position:y",
		ember.position.y - randf_range(10.0, 25.0),
		0.45
	)

	# Wait for parallel animations to finish,
	# then delete the ember
	tween.set_parallel(false)

	tween.tween_callback(
		ember.queue_free
	)


func _on_body_entered(body):
	if body.name == "Juni":
		body.take_damage(damage)
		queue_free()
