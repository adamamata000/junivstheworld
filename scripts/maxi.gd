extends CharacterBody2D

@export var projectile_scene: PackedScene
@export var minimum_throw_time = 1.5
@export var maximum_throw_time = 3.0

@export var idle_scale = Vector2(1.0, 1.0)
@export var attack_scale = Vector2(1.3, 1.3)

# Which frame of the attack animation releases the projectile
@export var throw_frame = 3

@onready var animated_sprite = $AnimatedSprite2D
@onready var throw_point = $ThrowPoint

var juni
var is_attacking = false
var projectile_thrown = false


func _ready():
	animated_sprite.scale = idle_scale
	juni = get_tree().current_scene.get_node("Juni")

	start_throw_timer()


func _physics_process(_delta):
	# While attack animation is playing,
	# wait until the correct frame to release projectile
	if is_attacking:
		if animated_sprite.frame >= throw_frame and not projectile_thrown:
			throw_projectile()
			projectile_thrown = true


func start_throw_timer():
	var wait_time = randf_range(
		minimum_throw_time,
		maximum_throw_time
	)

	await get_tree().create_timer(wait_time).timeout

	start_attack()


func start_attack():
	if is_attacking:
		return

	is_attacking = true
	projectile_thrown = false

	# Make smaller attack sprites match idle size
	animated_sprite.scale = attack_scale
	animated_sprite.play("attack")

	await animated_sprite.animation_finished

	is_attacking = false

	# Restore normal size
	animated_sprite.scale = idle_scale

	if animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")

	start_throw_timer()


func throw_projectile():
	if projectile_scene == null:
		return

	if juni == null:
		return

	var projectile = projectile_scene.instantiate()

	get_tree().current_scene.add_child(projectile)

	projectile.global_position = throw_point.global_position

	# Lock onto Juni's position at the moment Maxi throws
	projectile.aim_at(juni.global_position)
