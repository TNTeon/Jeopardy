extends Control

signal changeName

@onready var button: Button = $Button
@onready var text_edit: TextEdit = $TextEdit

func _on_button_pressed() -> void:
	if text_edit.text.length() > 0:
		changeName.emit(text_edit.text)
