extends Node
class_name category

@export var title = ""
@export var tileSetup : Array[tileResource]
@export var _questionTileScene : PackedScene

@onready var _v_box_container = $VBoxContainer
@onready var _title_text : RichTextLabel = $VBoxContainer/TitlePanel/TitleText

func _ready():
	_title_text.text = "[b]"+title
	for i in tileSetup:
		var newTile : QuestionTile = _questionTileScene.instantiate()
		_v_box_container.add_child(newTile)
		newTile.initialize(i.pointValue,i.Question,i.Answer)
