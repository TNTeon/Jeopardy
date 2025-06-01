extends Button

signal selected

@export var whiteTheme = true

func _on_pressed() -> void:
	selected.emit(text)
