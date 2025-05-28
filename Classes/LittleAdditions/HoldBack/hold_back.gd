extends Node

signal backout

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("exit"):
		$TextureRect/AnimationPlayer.play("load")
	if Input.is_action_just_released("exit"):
		$TextureRect/AnimationPlayer.play("RESET")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "load":
		backout.emit()
