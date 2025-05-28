extends Node

const NAME_SET = preload("res://Classes/Networking/Clinet/NameSet.tscn")

@onready var function: RichTextLabel = $Function
@export var host : bool = true

var port = 9999
const address = "127.0.0.1"
var multiplayer_peer = ENetMultiplayerPeer.new()

var id_dictionary = {}

#TODO remove all "#testing" lines

func _ready():
	if len(OS.get_cmdline_args()) > 1 and OS.get_cmdline_args()[1] == "client": #testing
		host = false #testing
	if !host:
		function.text = "Client"
		multiplayer_peer.create_client(address,port)
		multiplayer.multiplayer_peer = multiplayer_peer
		multiplayer.connected_to_server.connect(confirmClientConnection)
		return
	function.text = "Host" #testing
	multiplayer_peer.create_server(port)
	multiplayer.multiplayer_peer = multiplayer_peer

#region Host
@rpc("any_peer","call_remote","reliable")
func nameRequestRecieved(requestedName):
	var sender_id = multiplayer.get_remote_sender_id()
	if requestedName not in id_dictionary.values() or (id_dictionary.has(sender_id) and id_dictionary[sender_id] == requestedName):
		id_dictionary[sender_id] = requestedName
		rpc_id(sender_id, "replyNameChange",true)
	else:
		rpc_id(sender_id, "replyNameChange",false)

#endregion

#region Client
func confirmClientConnection():
	print("clinet connected!")
	var createNameSet = NAME_SET.instantiate()
	add_child(createNameSet)
	createNameSet.changeName.connect(requestNameChange)
	
func requestNameChange(requestedName):
	rpc_id(1,"nameRequestRecieved",requestedName)

@rpc("authority","call_remote","reliable")
func replyNameChange(worked : bool):
	print(worked)

#endregion
