extends Control

@onready var boardInstance : board = $HBoxContainer/Board

func _on_rows_int_select_value_changed(value: float) -> void:
	var newEmptyCategory = categoryResource.new()
	newEmptyCategory.questionTile.append(tileResource.new())
	boardInstance.categoryList.append(newEmptyCategory)
	boardInstance.initialize()
