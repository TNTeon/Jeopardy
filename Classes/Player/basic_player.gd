extends Control
class_name basic_player

@export var isPressed = false

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
func _ready():
	if !is_multiplayer_authority():
		visible = false

func _on_pressed():
	if is_multiplayer_authority():
		isPressed = true
