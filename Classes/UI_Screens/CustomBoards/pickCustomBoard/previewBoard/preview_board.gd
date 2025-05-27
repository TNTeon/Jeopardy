extends Control

@onready var board_name: RichTextLabel = $VSplitContainer/Panel/BoardName
@onready var categoryPanel: Panel = $VSplitContainer/Panel2/StoreCategories/Category
@onready var store_categories: HBoxContainer = $VSplitContainer/Panel2/StoreCategories

signal boardSelected
signal deleteBoard

func initialize(name : String, categories : Array[categoryResource]):
	board_name.text = name
	categoryPanel.get_child(0).text = categories[0].title
	
	var skipedFirst = false
	for i in categories:
		if skipedFirst:
			setCategory(i)
		else:
			skipedFirst = true
		
func setCategory(cat : categoryResource):
	var newCatPanel = categoryPanel.duplicate()
	store_categories.add_child(newCatPanel)
	newCatPanel.get_child(0).text = cat.title


func _on_button_pressed() -> void:
	boardSelected.emit(board_name.text)

func _on_delete_but_pressed() -> void:
	self.queue_free()
	deleteBoard.emit(board_name.text)
