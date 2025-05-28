extends "res://Classes/Board/board.gd"

var database : SQLite
var amount_of_categories : int

func _ready():
	database = SQLite.new()
	database.path = "res://Classes/Category/showCategories.db"
	database.open_db()
	database.query("SELECT COUNT(*) FROM category;")
	amount_of_categories = int(database.query_result[0]["COUNT(*)"])
	
	for i in range(5):
		categoryList.append(randomCategory())
	initialize()

func displayCategory(cat : categoryResource):
	print(cat.title)
	for i in range(5):
		print(cat.questionTile[i].Question)
		print(cat.questionTile[i].Answer)
		print(cat.questionTile[i].pointValue)
		print("")

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
