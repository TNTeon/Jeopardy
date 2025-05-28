extends Node
class_name EditableCategory

var selfResource = categoryResource.new()

@export var title = ""
@export var _questionTileScene : PackedScene

@onready var storeTiles = $VBoxContainer
@onready var _title_text : RichTextLabel = $VBoxContainer/TitlePanel/TitleText
@onready var dead_tiles: Control = $DeadTiles
@onready var title_panel: Panel = $VBoxContainer/TitlePanel

var EditablePlayable : editablePlayable
signal selected

var numberOfTiles = 0
func update():
	_title_text.text = "[b]"+title.to_upper()
	selfResource.title = _title_text.text
	selfResource.questionTile.clear()
	for i in storeTiles.get_children():
		if i is EditableTile:
			selfResource.questionTile.append(i.selfResource)

func initalize(columns : int, base : Control):
	update()
	EditablePlayable = base
	selected.connect(base.newSelection)
	base.removeSelections.connect(clearSelection)
	for i in range(columns):
		newTile()
func initalizeWithTiles(tiles : Array[tileResource],base : Control):
	update()
	EditablePlayable = base
	selected.connect(base.newSelection)
	base.removeSelections.connect(clearSelection)
	for i in tiles:
		loadTile(i)

func loadTile(tile : tileResource):
	numberOfTiles += 1
	var newTile : EditableTile = _questionTileScene.instantiate()
	storeTiles.add_child(newTile)
	newTile.initialize(tile.pointValue,tile.Question,tile.Answer,EditablePlayable)

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
	update()
	
func removeTile():
	var child = storeTiles.get_child(storeTiles.get_child_count()-1)
	child.reparent(dead_tiles)
	child.visible = false
	if EditablePlayable.currentSelection == child:
		selected.emit(null)
	numberOfTiles -= 1
	update()
	
func updateColumns(columns : int):
	while columns > numberOfTiles:
		newTile()
	while columns < numberOfTiles:
		removeTile()
		
func checkIfSelected():
	if EditablePlayable.currentSelection == self:
		selected.emit(null)
		return
	for i in storeTiles.get_children():
		if EditablePlayable.currentSelection == i:
			selected.emit(null)
			break

func _on_button_pressed() -> void:
	selected.emit(self)
	var new_stylebox_normal = title_panel.get_theme_stylebox("panel").duplicate()
	new_stylebox_normal.border_color = Color.DARK_BLUE
	title_panel.add_theme_stylebox_override("panel", new_stylebox_normal)
	
func clearSelection():
	title_panel.remove_theme_stylebox_override("panel")
