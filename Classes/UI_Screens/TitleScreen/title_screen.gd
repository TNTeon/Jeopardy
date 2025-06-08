extends Control

var database : SQLite
var amount_of_categories : int

func _on_random_but_pressed() -> void:
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
	var listCategories : Array[categoryResource] = []
	for i in range(5):
		listCategories.append(randomCategory())
	TransferInformation.loadBoard = listCategories
	TransferInformation.isHost = true
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://Classes/Networking/networkController.tscn")

func _on_custom_but_pressed() -> void:
	get_tree().change_scene_to_file("res://Classes/UI_Screens/CustomBoards/pickCustomBoard/pickCustomBoard.tscn")

func _on_exit_but_pressed() -> void:
	get_tree().quit()

	
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

func _on_button_pressed():
	get_tree().change_scene_to_file("res://Classes/Networking/networkController.tscn")
