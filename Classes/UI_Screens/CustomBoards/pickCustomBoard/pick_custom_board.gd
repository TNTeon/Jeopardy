extends CanvasLayer

var database : SQLite
var allBoards : Array[newBoard] = []

const BoardPath = "res://Classes/Board/Board.tscn"
const EditablePlayablePath = "res://Classes/Editables/EdtiablePlayable/EditablePlayable.tscn"
const PREVIEW_BOARD = preload("res://Classes/UI_Screens/CustomBoards/pickCustomBoard/previewBoard/previewBoard.tscn")
@onready var storePreviews: VBoxContainer = $VSplitContainer/ScrollContainer/VBoxContainer
@onready var find_file = $LoadBoard/findFile
@onready var set_name_window = $LoadBoard/setNameWindow

func _ready():
	database = SQLite.new()
	
	var DATABASE_PATH_RES = "res://customCategories.db"
	var DATABASE_PATH = "user://customCategories.db"
	if not FileAccess.file_exists(DATABASE_PATH):
		DirAccess.copy_absolute(DATABASE_PATH_RES,DATABASE_PATH)
		print("Copied db file to users dir")
	database.path = DATABASE_PATH
	database.open_db()
	
	database.query("SELECT * FROM board")
	for i in database.query_result:
		allBoards.append(newBoard.new(i["name"],database))
		
	for i in allBoards:
		var newPreviewInstance = PREVIEW_BOARD.instantiate()
		storePreviews.add_child(newPreviewInstance)
		newPreviewInstance.initialize(i.name,i.Categories)
		newPreviewInstance.boardSelected.connect(loadBoard)
		newPreviewInstance.deleteBoard.connect(deleteBoard)
		newPreviewInstance.editBoard.connect(editBoard)
			
func loadBoard(boardName : String):
	for i in allBoards:
		if i.name == boardName:
			TransferInformation.loadBoard = i.Categories
			TransferInformation.isHost = true
			get_tree().change_scene_to_file("res://Classes/Networking/networkController.tscn")
			return
class newBoard:
	var name : String = ""
	var Categories : Array[categoryResource] = []

	func _init(Name : String, db : SQLite):
		name = Name
		db.query("SELECT * FROM category WHERE BoardName='"+name+"'")
		for i in db.query_result:
			var newCategory = categoryResource.new()
			newCategory.title = i["title"]
			db.query("SELECT * FROM tile WHERE CategoryID='"+str(i["id"])+"'")
			for j in db.query_result:
				var newTile = tileResource.new()
				newTile.Answer = j["Answer"]
				newTile.pointValue = j["pointValue"]
				newTile.Question = j["Question"]
				newCategory.questionTile.append(newTile)
			Categories.append(newCategory)
			


func _on_back_but_pressed() -> void:
	get_tree().change_scene_to_file("res://Classes/UI_Screens/TitleScreen/titleScreen.tscn")

func deleteBoard(boardName : String):
	database.query("SELECT * FROM board WHERE name='"+boardName+"'")
	database.query("SELECT * FROM category WHERE BoardName='"+boardName+"'")
	for cat in database.query_result:
		database.delete_rows("tile","CategoryID='"+str(cat["id"])+"'")
		database.delete_rows("category","id='"+str(cat["id"])+"'")
	database.delete_rows("board","name='"+boardName+"'")

func editBoard(boardName : String):
	TransferInformation.editBoardSelected = boardName
	get_tree().change_scene_to_file("res://Classes/Editables/EdtiablePlayable/EditablePlayable.tscn")


func _on_new_board_pressed() -> void:
	get_tree().change_scene_to_file("res://Classes/Editables/EdtiablePlayable/EditablePlayable.tscn")

func _on_load_board_pressed():
	find_file.visible = true

func _on_file_dialog_file_selected(path):
	if ResourceLoader.exists(path):
		var loadedFile = ResourceLoader.load(path)
		if check_resource(loadedFile,boardResource.new()):
			set_name_window.visible = true
			await set_name_window.selectionMade
			var board_name = set_name_window.set_name.text
			nameSelectedForImport(loadedFile, board_name)
			
func nameSelectedForImport(boardRes : boardResource, board_name):
	if board_name != "":
		database.query("SELECT exists(SELECT 1 FROM board WHERE name = '"+board_name+"') AS row_exists;")
		var boardDictionary = {}
		while database.query_result[0]["row_exists"]:
			board_name = "Imported " + board_name
			boardDictionary["name"] = board_name
			database.query("SELECT exists(SELECT 1 FROM board WHERE name = '"+board_name+"') AS row_exists;")
		boardDictionary["name"] = board_name
		database.insert_row("board",boardDictionary)
		for i in boardRes.categories:
			var newCatDic = {}
			newCatDic["title"] = i.title
			newCatDic["BoardName"] = board_name
			database.insert_row("category",newCatDic)
			var lastID = database.last_insert_rowid
			for j in i.questionTile:
				var newTileDic = {}
				newTileDic["pointValue"] = j.pointValue
				newTileDic["Question"] = j.Question
				newTileDic["Answer"] = j.Answer
				newTileDic["CategoryID"] = lastID
				database.insert_row("tile",newTileDic)
		var newPreviewInstance = PREVIEW_BOARD.instantiate()
		storePreviews.add_child(newPreviewInstance)
		newPreviewInstance.initialize(board_name,boardRes.categories)
		newPreviewInstance.boardSelected.connect(loadBoard)
		newPreviewInstance.deleteBoard.connect(deleteBoard)
		newPreviewInstance.editBoard.connect(editBoard)

func check_resource(resource:Resource, filter:Resource) -> bool:
	var script:Script = resource.get_script()
	while script != null:
		if script == filter.get_script():
			return true
		script = script.get_base_script()
	return false
