extends ColorRect

@export var speed = 0.25
@export var min_brightness = 0.02
@export var max_brightness = 0.09

var time = 0.0

func _process(delta):
	time += delta * speed

	# Combine two waves so the sunlight doesn't repeat obviously
	var wave1 = sin(time)
	var wave2 = sin(time * 2.37) * 0.3

	var sunlight = (wave1 + wave2 + 1.3) / 2.6
	sunlight = clamp(sunlight, 0.0, 1.0)

	# Change transparency
	color.a = lerp(min_brightness, max_brightness, sunlight)

	# Very subtle colour temperature change
	var cool_color = Color(1.0, 0.88, 0.68)
	var warm_color = Color(1.0, 0.72, 0.38)

	var new_color = cool_color.lerp(warm_color, sunlight)

	color.r = new_color.r
	color.g = new_color.g
	color.b = new_color.b
