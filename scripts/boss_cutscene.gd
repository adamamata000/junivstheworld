extends Control

@onready var speaker_name = $DialogueBox/SpeakerName
@onready var dialogue_text = $DialogueBox/DialogueText
@onready var next_sound = $Next

# Dialogue settings
@export var typing_speed = 0.04

var current_line = 0
var is_typing = false

var dialogue = [
	{
		"speaker": "Maxi",
		"text": "Well, well, well..."
	},
	{
		"speaker": "Maxi",
		"text": "So you're the cat causing all this trouble."
	},
	{
		"speaker": "Juni",
		"text": "Meow."
	},
	{
		"speaker": "Maxi",
		"text": "...I'll take that as a threat."
	},
	{
		"speaker": "Maxi",
		"text": "Let's see how tough you really are."
	}
]


func _ready():
	Engine.time_scale = 1.0
	show_current_line()


func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		
		# If text is still typing, finish it instantly
		if is_typing:
			dialogue_text.visible_ratio = 1.0
			is_typing = false
		
		# Otherwise go to next line
		else:
			next_sound.play()
			next_line()


func show_current_line():
	var line = dialogue[current_line]

	speaker_name.text = line["speaker"]
	dialogue_text.text = line["text"]

	# Hide all the text
	dialogue_text.visible_ratio = 0.0

	is_typing = true

	# Start typewriter effect
	type_text()


func type_text():
	var total_characters = dialogue_text.text.length()

	for i in range(total_characters + 1):
		
		# Stop if player skipped the animation
		if not is_typing:
			return

		dialogue_text.visible_characters = i

		await get_tree().create_timer(typing_speed).timeout

	# Finished typing
	is_typing = false


func next_line():
	current_line += 1

	if current_line >= dialogue.size():
		start_boss_fight()
	else:
		show_current_line()


func start_boss_fight():
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file("res://boss_fight.tscn")
