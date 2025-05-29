extends Node

var editBoardSelected : String = ""
var loadBoard : Array[categoryResource] = []

#FIXME I just need an example loaded board for network stuff
func _ready():
	var cat = categoryResource.new()
	cat.title = "example board"
	cat.questionTile.append(tileResource.new())
	loadBoard.append(cat)
