extends Control
class_name editablePlayable

@onready var editable_board: EditableBoard = $HBoxContainer/EditableBoard
@onready var board_name: TextEdit = $HBoxContainer/VBoxContainer/boardName
@onready var rows_int_select: SpinBox = $HBoxContainer/VBoxContainer/RowsIntSelect
@onready var columns_int_select: SpinBox = $HBoxContainer/VBoxContainer/ColumnsIntSelect

var rows = 1
var columns = 1

var database : SQLite
var currentSelection = null

@onready var tile_edit: VBoxContainer = $HBoxContainer/VBoxContainer/TileEdit
@onready var pvInput = $HBoxContainer/VBoxContainer/TileEdit/pvInput
@onready var quInput : TextEdit = $HBoxContainer/VBoxContainer/TileEdit/quInput
@onready var anInput : TextEdit = $HBoxContainer/VBoxContainer/TileEdit/anInput

@onready var category_edit: VBoxContainer = $HBoxContainer/VBoxContainer/CategoryEdit
@onready var title_input: TextEdit = $HBoxContainer/VBoxContainer/CategoryEdit/titleInput

var autoChanging = false

signal removeSelections

func _ready():
	tile_edit.visible = false
	category_edit.visible = false
	database = SQLite.new()
	database.path = "res://customCategories.db"
	database.open_db()
	_on_rows_int_select_value_changed(5)
	_on_columns_int_select_value_changed(5)
	if TransferInformation.editBoardSelected != "":
		loadBoard(TransferInformation.editBoardSelected)
		TransferInformation.editBoardSelected = ""


func _on_rows_int_select_value_changed(value: float) -> void:
	rows = int(value)
	while rows > editable_board.numberOfCategories:
		editable_board.newCategory(columns, self)
	while rows < editable_board.numberOfCategories:
		editable_board.removeCategory()
	editable_board.updateColumns(columns)
	
func _on_columns_int_select_value_changed(value: float) -> void:
	print("value:", value)
	columns = int(value)
	editable_board.updateColumns(columns)

func newSelection(node):
	removeSelections.emit()
	currentSelection = node
	if node is EditableTile:
		var tileResouce = node.selfResource
		tile_edit.visible = true
		category_edit.visible = false
		
		if pvInput.value != tileResouce.pointValue:
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
	elif node is EditableCategory:
		var catResouce = node.selfResource
		tile_edit.visible = false
		category_edit.visible = true
		if catResouce.title != "No Title":
			title_input.text = catResouce.title.replace("[b]","")
		else:
			title_input.text = ""
		
	else:
		tile_edit.visible = false
		category_edit.visible = false
	
func tile_input_changed(test = null) -> void:
	if currentSelection is EditableTile and not autoChanging:
		currentSelection.update(int(pvInput.value), quInput.text.to_upper(), anInput.text.to_upper())
	if autoChanging:
		autoChanging = false
		
func cat_input_changed() -> void:
	if currentSelection is EditableCategory and not autoChanging:
		currentSelection.title = title_input.text
		currentSelection.update()
	if autoChanging:
		autoChanging = false

func save():
	database.query("SELECT exists(SELECT 1 FROM board WHERE name = '"+board_name.text+"') AS row_exists;")
	if not database.query_result[0]["row_exists"]:
		var boardDictionary = {}
		boardDictionary["name"] = board_name.text
		database.insert_row("board",boardDictionary)
	database.query("SELECT * FROM category WHERE BoardName='"+board_name.text+"'")
	var categoryIDs = []
	for i in database.query_result:
		categoryIDs.append(i["id"])
		database.delete_rows("category", "BoardName='"+board_name.text+"'")
	for i in categoryIDs:
		database.delete_rows("tile", "CategoryID="+str(i))
	for i in editable_board.storeCategories.get_children():
		if i is EditableCategory:
			var newCatDic = {}
			newCatDic["title"] = i.selfResource.title.replace("[b]","")
			newCatDic["BoardName"] = board_name.text
			database.insert_row("category",newCatDic)
			var lastID = database.last_insert_rowid
			for j in i.storeTiles.get_children():
				if j is EditableTile:
					var newTileDic = {}
					newTileDic["pointValue"] = j.selfResource.pointValue
					newTileDic["Question"] = j.selfResource.Question
					newTileDic["Answer"] = j.selfResource.Answer
					newTileDic["CategoryID"] = lastID
					database.insert_row("tile",newTileDic)

func _on_exit_but_pressed() -> void:
	get_tree().change_scene_to_file("res://Classes/UI_Screens/CustomBoards/pickCustomBoard/pickCustomBoard.tscn")

func loadBoard(boardName : String):
	rows_int_select.allow_lesser = true
	columns_int_select.allow_lesser = true
	rows_int_select.value = 0
	columns_int_select.value = 0
	board_name.text = boardName
	database.query("SELECT * FROM category WHERE BoardName='"+boardName+"'")
	var countRows = 0
	var countColumns = 0
	for categoryDictionary in database.query_result:
		countRows += 1
		var newCat = categoryResource.new()
		newCat.title = categoryDictionary["title"]
		database.query("SELECT * FROM tile WHERE CategoryID='"+str(categoryDictionary["id"])+"'")
		countColumns = 0
		for tileDictionary in database.query_result:
			countColumns += 1
			var newTile = tileResource.new()
			newTile.Answer = tileDictionary["Answer"]
			newTile.Question = tileDictionary["Question"]
			newTile.pointValue = tileDictionary["pointValue"]
			newCat.questionTile.append(newTile)
		editable_board.loadCategory(newCat, self)
	rows_int_select.value = countRows
	columns_int_select.value = countColumns
	rows_int_select.allow_lesser = false
	columns_int_select.allow_lesser = false
	
