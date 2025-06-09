extends Control

@onready var take_away_points_but = $VScrollBar/VBoxContainer/gameplay/VBoxContainer2/takeAwayPointsBut
@onready var timeout_input = $VScrollBar/VBoxContainer/gameplay/VBoxContainer/timeoutInput

func _ready():
	if TransferInformation.removePoints:
		take_away_points_but.button_pressed = true
		take_away_points_but.text = "Enabled"
	else:
		take_away_points_but.button_pressed = false
		take_away_points_but.text = "Disabled"
	timeout_input.value = TransferInformation.timeoutAmount

func _timeout_value_changed(value):
	TransferInformation.timeoutAmount = value

func _on_hold_back_backout():
	get_tree().change_scene_to_file("res://Classes/UI_Screens/TitleScreen/titleScreen.tscn")

func _on_take_away_points_but_pressed():
	take_away_points_but.release_focus()
	if take_away_points_but.button_pressed:
		print("enable")
		take_away_points_but.text = "Enabled"
		TransferInformation.removePoints = true
	else:
		print("disable")
		take_away_points_but.text = "Disabled"
		TransferInformation.removePoints = false
