extends Control
class_name EditableBoard

@export var categoryScene : PackedScene
@onready var storeCategories = $HBoxContainer

@onready var dead_categories: Control = $DeadCategories

var numberOfCategories = 0

func loadCategory(cat : categoryResource, base : Control):
	var newCat : EditableCategory = categoryScene.instantiate()
	storeCategories.add_child(newCat)
	newCat.title = cat.title
	newCat.initalizeWithTiles(cat.questionTile, base)
	numberOfCategories += 1

func newCategory(columns : int, base : Control):
	if dead_categories.get_child_count() == 0:
		var newCat : EditableCategory = categoryScene.instantiate()
		storeCategories.add_child(newCat)
		newCat.title = "No Title"
		newCat.initalize(columns, base)
	else:
		var child = dead_categories.get_child(dead_categories.get_child_count()-1)
		child.reparent(storeCategories)
		child.visible = true
	numberOfCategories += 1
	
func removeCategory():
	var child = storeCategories.get_child(storeCategories.get_child_count()-1)
	child.reparent(dead_categories)
	child.visible = false
	child.checkIfSelected()
	numberOfCategories -= 1
	
func updateColumns(columns : int):
	for i in storeCategories.get_children():
		i.updateColumns(columns)
