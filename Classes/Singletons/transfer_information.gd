extends Node

var editBoardSelected : String = ""
var loadBoard : Array[categoryResource] = []

#FIXME I just need an example loaded board for network stuff
func _ready():
	var queston = tileResource.new()
	queston.Question = "how old is Teon?"
	queston.Answer = "20"
	queston.pointValue = 175
	var cat = categoryResource.new()
	cat.title = "example board"
	cat.questionTile.append(queston)
	loadBoard.append(cat)
