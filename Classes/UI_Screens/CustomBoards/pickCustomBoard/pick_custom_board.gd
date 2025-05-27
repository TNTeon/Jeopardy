extends CanvasLayer

var database : SQLite
var allBoards : Array[newBoard] = []

const BoardPath = "res://Classes/Board/Board.tscn"
const PREVIEW_BOARD = preload("res://Classes/UI_Screens/CustomBoards/pickCustomBoard/previewBoard/previewBoard.tscn")
@onready var storePreviews: VBoxContainer = $VSplitContainer/ScrollContainer/VBoxContainer

func _ready():
	database = SQLite.new()
	database.path = "res://customCategories.db"
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
			
func loadBoard(boardName : String):
	for i in allBoards:
		if i.name == boardName:
			var createNewBoard = load(BoardPath)
			createNewBoard = createNewBoard.instantiate()
			createNewBoard.categoryList = i.Categories
			get_tree().get_root().add_child(createNewBoard)
			get_tree().get_root().remove_child(self)
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
	get_tree().change_scene_to_file("res://Classes/UI_Screens/CustomBoards/CustomBoardOptions/customBoardOptions.tscn")

func deleteBoard(boardName : String):
	database.query("SELECT * FROM board WHERE name='"+boardName+"'")
	database.query("SELECT * FROM category WHERE BoardName='"+boardName+"'")
	for cat in database.query_result:
		database.delete_rows("tile","CategoryID='"+str(cat["id"])+"'")
		database.delete_rows("category","id='"+str(cat["id"])+"'")
	database.delete_rows("board","name='"+boardName+"'")
