extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var player_scene : PackedScene
#This is where we store our players
@onready var players = $Players
@onready var host: Button = $host
@onready var join: Button = $join

#Holds the currently buzzed player
var buzzed_player : basic_player

var isHost : bool

func _on_host_pressed():
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	
	isHost = true
	
	setup_Host_View()	
	
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	players.add_child(player)

func _on_join_pressed():
	peer.create_client("192.168.1.61",135)
	multiplayer.multiplayer_peer = peer
	
	isHost = false
	setup_Client_View()

func _process(delta):
	#HACK we would love to do this without a loop! Maybe with signals???????
	#If no one has buzzed, allow them to!
	if !buzzed_player:
		for i in players.get_children():
			if i.isPressed:
				buzzed_player = i
				print(i.name, " buzzed in!")
	#If someone has already buzzed, earse anyone else's buzz
	else:
		for i in players.get_children():
			i.isPressed = false
func _input(event):
	if Input.is_action_just_pressed("ui_down"):
		clearBuzzedPlayer()

#Clear last buzzed player, allow more to now buzz
func clearBuzzedPlayer():
	buzzed_player = null
	
func setup_Host_View():
	pass
	
func setup_Client_View():
	host.visible = false
	join.visible = false
