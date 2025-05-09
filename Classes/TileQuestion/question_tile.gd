extends Control
class_name QuestionTile

@export var point_value : int = 100
@export var question : String = ""

var buzzer

func initialize(pv : int, qu : String):
	point_value = pv
	question = qu
