extends Node
class_name EditableCategory

@export var title = ""
@export var _questionTileScene : PackedScene

@onready var storeTiles = $VBoxContainer
@onready var _title_text : RichTextLabel = $VBoxContainer/TitlePanel/TitleText
@onready var dead_tiles: Control = $DeadTiles

var EditablePlayable : editablePlayable
signal selected

var numberOfTiles = 0
func update():
	_title_text.text = "[b]"+title

func initalize(columns : int, base : Control):
	update()
	EditablePlayable = base
	selected.connect(base.newSelection)
	for i in range(columns):
		newTile()

func newTile():
	numberOfTiles += 1
	if dead_tiles.get_child_count() == 0:
		var newTile : EditableTile = _questionTileScene.instantiate()
		storeTiles.add_child(newTile)
		var value = numberOfTiles*100
		newTile.initialize(value,"","",EditablePlayable)
	else:
		var child = dead_tiles.get_child(dead_tiles.get_child_count()-1)
		child.reparent(storeTiles)
		child.visible = true
	
func removeTile():
	var child = storeTiles.get_child(storeTiles.get_child_count()-1)
	child.reparent(dead_tiles)
	child.visible = false
	if EditablePlayable.currentSelection == child:
		selected.emit(null)
	numberOfTiles -= 1
	
func updateColumns(columns : int):
	while columns > numberOfTiles:
		newTile()
	while columns < numberOfTiles:
		removeTile()
		
func checkIfSelected():
	for i in storeTiles.get_children():
		if EditablePlayable.currentSelection == i:
			selected.emit(null)
			break
