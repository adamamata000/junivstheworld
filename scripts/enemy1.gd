extends CharacterBody2D

# Movement
@export var speed = 100.0
@export var attack_distance = 120.0
@export var attack_damage = 10

# Knockback
@export var knockback_strength = 220.0
@export var knockback_deceleration = 1200.0

# Hit flash
@export var hit_flash_duration = 0.08

# Score
@export var score_value = 1

# Health
@export var max_health = 30
var health = 30

# Nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_hitbox = $AttackHitbox
@onready var hit_impact = $HitImpact

# Player
var player

# State
var is_attacking = false
var is_hurt = false
var is_dead = false
var has_dealt_damage = false


func _ready():
	player = get_tree().current_scene.get_node("Juni")
	health = max_health


func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Don't chase or attack while hurt/dead
	if player and not is_hurt and not is_dead:
		var distance_to_player = abs(
			player.global_position.x - global_position.x
		)

		var direction = sign(
			player.global_position.x - global_position.x
		)

		# Face Juni
		if direction > 0:
			animated_sprite.flip_h = false
		elif direction < 0:
			animated_sprite.flip_h = true

		# Attack
		if distance_to_player <= attack_distance:
			velocity.x = 0

			if not is_attacking:
				start_attack()

		# Chase Juni
		elif not is_attacking:
			velocity.x = direction * speed
			animated_sprite.play("walk")

	else:
		# Knockback movement while hurt
		if is_hurt:
			velocity.x = move_toward(
				velocity.x,
				0,
				knockback_deceleration * delta
			)
		else:
			velocity.x = 0

	move_and_slide()

	# Check if attack hits Juni
	if is_attacking and not is_dead:
		check_attack_damage()


func start_attack():
	is_attacking = true
	has_dealt_damage = false
	animated_sprite.play("attack")


func check_attack_damage():
	if has_dealt_damage:
		return

	# Attack connects on frame 2
	if animated_sprite.frame >= 2:
		var bodies = attack_hitbox.get_overlapping_bodies()

		for body in bodies:
			if body == player:
				player.take_damage(attack_damage)
				has_dealt_damage = true


func take_damage(amount, knockback_direction = 0):
	if is_dead:
		return

	health -= amount
	health = clamp(health, 0, max_health)

	# Play hit sound
	hit_impact.play()

	# Flash when hit
	hit_flash()

	# Interrupt attack
	is_attacking = false

	# Apply knockback
	velocity.x = knockback_direction * knockback_strength

	if health <= 0:
		die()
	else:
		is_hurt = true
		animated_sprite.play("hurt")


func hit_flash():
	animated_sprite.modulate = Color(3, 3, 3, 1)

	await get_tree().create_timer(hit_flash_duration).timeout

	animated_sprite.modulate = Color.WHITE


func die():
	is_dead = true
	is_attacking = false
	is_hurt = false
	velocity.x = 0

	# Give Juni points for killing this enemy
	var score_ui = get_tree().current_scene.get_node("ScoreUI")
	score_ui.add_score(score_value)

	animated_sprite.play("die")


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "attack":
		is_attacking = false

	elif animated_sprite.animation == "hurt":
		is_hurt = false

	elif animated_sprite.animation == "die":
		queue_free()
