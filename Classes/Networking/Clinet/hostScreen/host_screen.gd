extends CanvasLayer
class_name hostScreen

@onready var display_question = $QuestionPanel/displayQuestion
@onready var display_answer = $AnswerPanel/displayAnswer
@onready var display_pv = $PointPanel/displayPV

func _ready():
	display_question.text = ""
	display_answer.text = ""
	display_pv.text = ""

func newTile(tile : Dictionary):
	display_question.text = tile["question"]
	display_answer.text = tile["answer"]
	display_pv.text = "[b]$"+str(tile["pointValue"])
