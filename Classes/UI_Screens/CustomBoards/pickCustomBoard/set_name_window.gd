extends Window

@onready var set_name = $VBoxContainer/setName

signal selectionMade

func _on_set_but_pressed():
	selectionMade.emit(TransferInformation.cleanUpText(set_name.text))
	set_name.text = ""
	visible = false

func _on_cancel_but_pressed():
	selectionMade.emit("")
	set_name.text = ""
	visible = false
