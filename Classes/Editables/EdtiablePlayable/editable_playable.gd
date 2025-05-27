extends Control
class_name editablePlayable

@onready var editable_board: EditableBoard = $HBoxContainer/EditableBoard

var rows = 1
var columns = 1

var currentSelection = null

@onready var tile_edit: VBoxContainer = $HBoxContainer/VBoxContainer/TileEdit
@onready var pvInput = $HBoxContainer/VBoxContainer/TileEdit/pvInput
@onready var quInput : TextEdit = $HBoxContainer/VBoxContainer/TileEdit/quInput
@onready var anInput : TextEdit = $HBoxContainer/VBoxContainer/TileEdit/anInput

var autoChanging = false

signal removeSelections

func _ready():
	tile_edit.visible = false
	_on_rows_int_select_value_changed(5)
	_on_columns_int_select_value_changed(5)


func _on_rows_int_select_value_changed(value: float) -> void:
	rows = int(value)
	while rows > editable_board.numberOfCategories:
		editable_board.newCategory(columns, self)
	while rows < editable_board.numberOfCategories:
		editable_board.removeCategory()
	editable_board.updateColumns(columns)
	
func _on_columns_int_select_value_changed(value: float) -> void:
	columns = int(value)
	editable_board.updateColumns(columns)

func newSelection(node : EditableTile):
	removeSelections.emit()
	currentSelection = node
	if node:
		var tileResouce = node.selfResource
		tile_edit.visible = true
		
		autoChanging = true
		pvInput.value = tileResouce.pointValue
		if tileResouce.Question != "":
			quInput.text = tileResouce.Question
		else:
			quInput.text = ""
		if tileResouce.Answer != "":
			anInput.text = tileResouce.Answer
		else:
			anInput.text = ""
	else:
		tile_edit.visible = false
		
func tile_input_changed(test = null) -> void:
	if currentSelection is EditableTile and not autoChanging:
		currentSelection.update(int(pvInput.value), quInput.text.to_upper(), anInput.text.to_upper())
	if autoChanging:
		autoChanging = false
