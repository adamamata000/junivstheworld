extends CharacterBody2D

# Movement
const SPEED = 420.0
const JUMP_VELOCITY = -460.0

# Health
@export var max_health = 100
var health = 100

# Combat
@export var attack_damage = 10
@export var powered_up_damage = 15
@export var hit_stop_duration = 0.05

# Hurt effects
@export var hurt_flash_duration = 0.1

# Nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var full_bar = $HealthBar/FullBar
@onready var attack_hitbox = $AttackHitbox
@onready var attack_sound = $AttackSound
@onready var damage_sound = $DamageSound

# Attack state
var is_attacking = false
var has_dealt_damage = false

# Power-up state
var is_powered_up = false

# Death state
var is_dead = false


func _ready():
	health = max_health
	update_health_bar()


func _physics_process(delta):
	# Don't allow movement after death
	if is_dead:
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Start attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY

	# Left / right movement
	var direction = Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = 0

	# Flip Juni
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Normal animations
	if not is_attacking:
		if not is_on_floor():
			animated_sprite.play("jump")
		elif direction != 0:
			animated_sprite.play("run")
		else:
			animated_sprite.play("idle")

	move_and_slide()

	# Check whether attack hits something
	if is_attacking:
		check_attack_damage()


func start_attack():
	is_attacking = true
	has_dealt_damage = false

	animated_sprite.play("attack")
	attack_sound.play()


func check_attack_damage():
	# Don't damage multiple times during one swing
	if has_dealt_damage:
		return

	# Juni's attack connects on frame 2
	if animated_sprite.frame >= 2:
		var bodies = attack_hitbox.get_overlapping_bodies()

		for body in bodies:
			if body.has_method("take_damage") and body != self:
				# Work out which direction enemy should be knocked
				var knockback_direction = sign(
					body.global_position.x - global_position.x
				)

				# Damage enemy
				body.take_damage(
					attack_damage,
					knockback_direction
				)

				has_dealt_damage = true

				# Brief freeze when hit connects
				hit_stop()

				break


func power_up():
	# Don't power up more than once
	if is_powered_up:
		return

	is_powered_up = true
	attack_damage = powered_up_damage

	print("Juni powered up! Damage: ", attack_damage)


func hit_stop():
	Engine.time_scale = 0.0

	await get_tree().create_timer(
		hit_stop_duration,
		true,
		false,
		true
	).timeout

	Engine.time_scale = 1.0


func take_damage(amount):
	# Can't take damage after dying
	if is_dead:
		return

	health -= amount
	health = clamp(health, 0, max_health)

	update_health_bar()

	# Flash Juni when she gets hit
	hurt_flash()

	# Play damage sound
	damage_sound.play()

	if health <= 0:
		die()


func hurt_flash():
	# Flash bright white
	animated_sprite.modulate = Color(3, 3, 3, 1)

	# Wait briefly
	await get_tree().create_timer(hurt_flash_duration).timeout

	# Return to normal
	animated_sprite.modulate = Color.WHITE


func update_health_bar():
	var health_percent = float(health) / float(max_health)

	full_bar.region_rect.size.x = 95.0 * health_percent


func die():
	if is_dead:
		return

	is_dead = true
	is_attacking = false
	velocity = Vector2.ZERO

	# Find Game Over screen
	var game_over_screen = get_tree().current_scene.get_node(
		"GameOverUI/GameOverScreen"
	)

	# Show Game Over screen
	game_over_screen.show()

	# Freeze the game
	get_tree().paused = true


func _on_animated_sprite_2d_animation_finished():
	if animated_sprite.animation == "attack":
		is_attacking = false
		animated_sprite.play("idle")
