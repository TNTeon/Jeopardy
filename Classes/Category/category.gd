extends Node
class_name category

@export var title = ""
@export var tileList : Array[tileResource]
@export var _questionTileScene : PackedScene

@onready var _v_box_container = $VBoxContainer
@onready var _title_text : RichTextLabel = $VBoxContainer/TitlePanel/TitleText

signal relaySelectedSignal
signal relayDyingSignal
signal relayAllowBuzzingSignal
signal relayStopBuzzingSignal
signal relayChangePointsSignal

func initalize():
	_title_text.text = "[b]"+title
	for i in tileList:
		var newTile : QuestionTile = _questionTileScene.instantiate()
		_v_box_container.add_child(newTile)
		newTile.initialize(i.pointValue,i.Question,i.Answer)
		newTile.selectedTile.connect(func(tile): relaySelectedSignal.emit(tile))
		newTile.tileDying.connect(func(tile): relayDyingSignal.emit(tile))
		newTile.allowBuzzing.connect(func(pastBuzz): relayAllowBuzzingSignal.emit(pastBuzz))
		newTile.stopBuzzing.connect(func(): relayStopBuzzingSignal.emit())
		newTile.changePoints.connect(func(plrName,points): relayChangePointsSignal.emit(plrName,points))
