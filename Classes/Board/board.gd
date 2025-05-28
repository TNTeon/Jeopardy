extends Control
class_name board

@export var categoryList : Array[categoryResource]
@export var categoryScene : PackedScene

@onready var _h_box_container = $HBoxContainer

func _ready():
	if not TransferInformation.loadBoard.is_empty():
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
