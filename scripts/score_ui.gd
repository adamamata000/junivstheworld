extends CanvasLayer

var score = 0

@onready var score_label = $ScoreLabel


func _ready():
	update_score()


func add_score(amount):
	score += amount
	update_score()


func update_score():
	score_label.text = str(score)
