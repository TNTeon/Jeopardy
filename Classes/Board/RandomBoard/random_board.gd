extends "res://Classes/Board/board.gd"

var database : SQLite
var amount_of_categories : int

func _ready():
	database = SQLite.new()
	var DATABASE_PATH_RES = "res://Classes/Category/showCategories.db"
	var DATABASE_PATH = "user://showCategories.db"
	if not FileAccess.file_exists(DATABASE_PATH):
		DirAccess.copy_absolute(DATABASE_PATH_RES,DATABASE_PATH)
		print("Copied db file to users dir")
	database.path = DATABASE_PATH
	database.open_db()
	database.query("SELECT COUNT(*) FROM category;")
	amount_of_categories = int(database.query_result[0]["COUNT(*)"])
	
	for i in range(5):
		categoryList.append(randomCategory())
	TransferInformation.loadBoard = categoryList
	TransferInformation.isHost = true
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Classes/Networking/networkController.tscn")
	
func createResource(id):
	id = str(id)
	var catInfo = database.select_rows("category","id = "+id, ["*"])[0]
	var tileInfo = database.select_rows("tile","CategoryID = "+id, ["*"])
	
	var resource = categoryResource.new()
	resource.title = catInfo["title"]
	for i in range(5):
		var tile = tileResource.new()
		tile.Answer = tileInfo[i]["Answer"]
		tile.Question = tileInfo[i]["Question"]
		tile.pointValue = tileInfo[i]["pointValue"]
		resource.questionTile.append(tile)
	return resource

func randomCategory():
	var randomChoice = randi_range(1,amount_of_categories)
	return createResource(randomChoice)
