extends Node
class_name category

@export var title = ""
@export var tileList : Array[tileResource]
@export var _questionTileScene : PackedScene

@onready var _v_box_container = $VBoxContainer
@onready var _title_text : RichTextLabel = $VBoxContainer/TitlePanel/TitleText

func initalize():
	_title_text.text = "[b]"+title
	for i in tileList:
		var newTile : QuestionTile = _questionTileScene.instantiate()
		_v_box_container.add_child(newTile)
		newTile.initialize(i.pointValue,i.Question,i.Answer)
