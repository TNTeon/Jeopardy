extends Control

@export var startTimer : bool
@export var timeDisplay : Label
@export var time : float = 0

var updateTime : bool = true
var peer = ENetMultiplayerPeer.new()

func _enter_tree():
	set_multiplayer_authority(name.to_int())
	
	peer.create_client("localhost",135)
	multiplayer.multiplayer_peer = peer

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
