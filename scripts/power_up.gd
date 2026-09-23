extends Area2D

@export var fall_speed = 150.0

@onready var ray_cast = $RayCast2D

@onready var power_up_sound = $PowerUpSound

var has_landed = false


func _ready():
	body_entered.connect(_on_body_entered)


func _process(delta):
	if has_landed:
		return

	if ray_cast.is_colliding():
		has_landed = true
		return

	position.y += fall_speed * delta


func _on_body_entered(body):
	if body.name == "Juni":
		body.power_up()

		# Hide the power-up
		$AnimatedSprite2D.hide()
		$CollisionShape2D.set_deferred("disabled", true)

		# Play pickup sound
		power_up_sound.play()

		# Wait for sound to finish
		await power_up_sound.finished

		# Delete power-up
		queue_free()
