extends AnimatedSprite2D

@export var speed = 20.0
@export var left_edge = 350.0
@export var right_edge = 950.0
@export var fade_distance = 100.0

func _process(delta):
	position.x -= speed * delta

	# Fade out as cloud approaches the left edge
	if position.x < left_edge + fade_distance:
		var fade_amount = (position.x - left_edge) / fade_distance
		modulate.a = clamp(fade_amount, 0.0, 1.0)

	# Reset cloud to the right
	if position.x < left_edge:
		position.x = right_edge
		modulate.a = 0.0

	# Fade back in after appearing on the right
	if position.x > right_edge - fade_distance:
		var fade_amount = (right_edge - position.x) / fade_distance
		modulate.a = clamp(fade_amount, 0.0, 1.0)
