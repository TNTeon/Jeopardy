extends Node

var database : SQLite

func _ready():
	var dir = "C:\\Users\\tnfal\\Desktop\\AllCategories"
	var files = DirAccess.get_files_at(dir)
	
	##THIS SHOULD BE REMOVED FOR FULL BATCH
	#files = files.slice(0, 1000)
	
	if FileAccess.file_exists("res://data.db"):
		print("yeah its there!")
		DirAccess.remove_absolute("res://data.db")
	
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
	
	var table = {
		"id" : {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment": true},
		"pointValue" : {"data_type":"int"},
		"Question" : {"data_type":"text"},
		"Answer" : {"data_type":"text"},
		"CategoryID" : {"data_type":"int"}
	}
	database.create_table("tile",table)
	
	table = {
		"id" : {"data_type":"int", "primary_key": true, "not_null": true, "auto_increment": true},
		"title" : {"data_type":"text"}
	}
	database.create_table("category",table)
	
	var i = 0
	for fileName in files:
		if i%1000 == 0:
			print(i)
		i += 1
		var categoryDictionary = {}
		var cat : categoryResource = ResourceLoader.load(dir+"\\"+fileName)
		categoryDictionary["title"] = cat.title
		database.insert_row("category",categoryDictionary)
		var CatID = database.last_insert_rowid
		
		var count = 1
		for tile in cat.questionTile:
			var tileDictionary = {}
			if tile.pointValue != count * 100:
				tileDictionary["pointValue"] = tile.pointValue/4
			else:
				tileDictionary["pointValue"] = tile.pointValue
			tileDictionary["Question"] = tile.Question
			tileDictionary["Answer"] = tile.Answer
			tileDictionary["CategoryID"] = CatID
			database.insert_row("tile",tileDictionary)
			count += 1
