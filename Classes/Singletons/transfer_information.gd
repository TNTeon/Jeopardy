extends Node

var editBoardSelected : String = ""

var isHost : bool = false
var loadBoard : Array[categoryResource] = []

func cleanUpText(text : String):
	text = text.replace("\n","")
	text = text.replace("\t","")
	text = text.replace("\\","")
	text = text.replace("/","")
	return text
