extends Node

var editBoardSelected : String = ""

var isHost : bool = false
var loadBoard : Array[categoryResource] = []
var timeoutAmount = 5
var removePoints = true

func cleanUpText(text : String):
	text = text.replace("\n","")
	text = text.replace("\t","")
	text = text.replace("\\","")
	text = text.replace("/","")
	return text
