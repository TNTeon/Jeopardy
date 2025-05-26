extends Control

func _on_create_but_pressed() -> void:
	pass

func _on_edit_but_pressed() -> void:
	pass

func _on_back_but_pressed() -> void:
	get_tree().change_scene_to_file("res://Classes/UI_Screens/TitleScreen/titleScreen.tscn")
