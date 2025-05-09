extends Control

@export var startTimer : bool
@export var timeDisplay : Label

var time : float = 0
var updateTime : bool = true

func _physics_process(delta: float):
	if updateTime:
		time += delta
	
	if startTimer:
		updateTime = true
		startTimer = false
		time = 0
		
	print(time)

func _on_button_pressed():
	updateTime = false
