extends CanvasLayer

signal confirmed

func _ready():
	visible = false
	
func requested():
	visible = true

func _on_yes_but_pressed() -> void:
	confirmed.emit()

func _on_no_but_pressed() -> void:
	visible = false
