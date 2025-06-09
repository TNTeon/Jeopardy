extends Control
class_name board

@export var categoryList : Array[categoryResource]
@export var categoryScene : PackedScene

@onready var store_categories: HBoxContainer = $VBoxContainer/StoreCategories
@onready var store_icons: HBoxContainer = $VBoxContainer/StoreIcons

var loadedGame : bool
var selectedTile : QuestionTile

signal allowBuzzing
signal stopBuzzing
signal newTile
signal changePlayerPoints

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
		store_categories.add_child(newCat)
		newCat.title = i.title
		newCat.tileList = i.questionTile
		newCat.relaySelectedSignal.connect(setSelectedTile)
		newCat.relayDyingSignal.connect(removeSelectedTile)
		newCat.relayAllowBuzzingSignal.connect(func(pastBuzz): allowBuzzing.emit(pastBuzz))
		newCat.relayStopBuzzingSignal.connect(func(): stopBuzzing.emit())
		newCat.relayChangePointsSignal.connect(func(plrName,points): changePlayerPoints.emit(plrName,points))
		newCat.initalize()


#func _on_hold_back_backout() -> void:
	#if loadedGame:
		#multiplayer.multiplayer_peer.close()
		#get_tree().change_scene_to_file("res://Classes/UI_Screens/CustomBoards/pickCustomBoard/pickCustomBoard.tscn")
	#else:
		#get_tree().change_scene_to_file("res://Classes/UI_Screens/TitleScreen/titleScreen.tscn")

func setSelectedTile(tile : QuestionTile):
	selectedTile = tile
	newTile.emit(tile)

func removeSelectedTile(tile : QuestionTile):
	if tile == selectedTile:
		selectedTile = null
		stopBuzzing.emit()
	else:
		push_error("Selected tile doens't match dying tile!")
		
func selectTile(catNumber, tileNumber):
	store_categories.get_child(catNumber).selectTile(tileNumber+1)
