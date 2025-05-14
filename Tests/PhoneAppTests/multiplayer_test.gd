extends Node2D

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
func _enter_tree():
	peer.create_server(135)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(_add_player)
	
func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child",player)

func _physics_process(_delta):
	print(self.get_children())
