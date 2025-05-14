extends Control

var peer = ENetMultiplayerPeer.new()

func _ready():
	peer.create_client("localhost",135)
	multiplayer.multiplayer_peer = peer
