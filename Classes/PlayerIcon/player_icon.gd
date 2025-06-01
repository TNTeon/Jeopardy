extends Control
class_name playerIcon

@onready var score_text: scaleableText = $AspectRatioContainer/VBoxContainer/scorePanel/scoreText
@onready var name_text: scaleableText = $AspectRatioContainer/VBoxContainer/namePanel/nameText

var score : int
var plrName : String

func updateScore(newScore):
	score = newScore
	score_text.text = "[b]$"+str(score)

func addToScore(additionalPoints):
	score += additionalPoints
	score_text.text = "[b]$"+str(score)

func updateName(newName):
	plrName = newName
	name_text.text = newName
