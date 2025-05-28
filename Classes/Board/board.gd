extends Control
class_name board

@export var categoryList : Array[categoryResource]
@export var categoryScene : PackedScene

@onready var _h_box_container = $HBoxContainer

var loadedGame : bool

func _ready():
	loadedGame = false
	if not TransferInformation.loadBoard.is_empty():
		loadedGame = true
		categoryList = TransferInformation.loadBoard
	if len(categoryList) > 0:
		print("init")
		initialize()

func initialize():
	if not categoryScene:
		push_error("MISSING CATEGORY SCENE")
		return
	for i in categoryList:
		var newCat : category = categoryScene.instantiate()
		_h_box_container.add_child(newCat)
		newCat.title = i.title
		newCat.tileList = i.questionTile
		newCat.initalize()


func _on_hold_back_backout() -> void:
	if loadedGame:
		get_tree().change_scene_to_file("res://Classes/UI_Screens/CustomBoards/pickCustomBoard/pickCustomBoard.tscn")
	else:
		get_tree().change_scene_to_file("res://Classes/UI_Screens/TitleScreen/titleScreen.tscn")
