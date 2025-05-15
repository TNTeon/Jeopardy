extends Control

@export var categoryList : Array[categoryResource]
@export var categoryScene : PackedScene

@onready var _h_box_container = $HBoxContainer

func _ready():
	for i in categoryList:
		var newCat : category = categoryScene.instantiate()
		_h_box_container.add_child(newCat)
		newCat.title = i.title
		newCat.tileList = i.questionTile
		newCat.initalize()
