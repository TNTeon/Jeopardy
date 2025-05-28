extends Control

func _on_random_but_pressed() -> void:
	get_tree().change_scene_to_file("res://Classes/Board/RandomBoard/randomBoard.tscn")

func _on_custom_but_pressed() -> void:
	get_tree().change_scene_to_file("res://Classes/UI_Screens/CustomBoards/pickCustomBoard/pickCustomBoard.tscn")

func _on_exit_but_pressed() -> void:
	get_tree().quit()
