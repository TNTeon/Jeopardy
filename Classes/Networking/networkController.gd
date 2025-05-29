extends Node

const CLIENT_SETUP = preload("res://Classes/Networking/Clinet/clientSetup.tscn")
const HOST_SETUP = preload("res://Classes/Networking/Host/hostSetup.tscn")
const BOARD = preload("res://Classes/Board/Board.tscn")

@onready var function: RichTextLabel = $Function
@export var host : bool = true

var port = 9999
const address = "127.0.0.1"
var multiplayer_peer = ENetMultiplayerPeer.new()

var id_dictionary = {}
var playerHostID : int = -1

#TODO remove all "#testing" lines

func _ready():
	#await get_tree().create_timer(1).timeout
	if len(OS.get_cmdline_args()) > 1 and OS.get_cmdline_args()[1] == "client": #testing
		host = false #testing
	if !host:
		function.text = "Client"
		multiplayer_peer.create_client(address,port)
		multiplayer.multiplayer_peer = multiplayer_peer
		multiplayer.connected_to_server.connect(confirmClientConnection)
	else:
		function.text = "Host" #testing
		multiplayer_peer.create_server(port)
		multiplayer.multiplayer_peer = multiplayer_peer
		serverCreated()

#region Host
var newBoard : board
var newHostSetup : hostSetup

func serverCreated():
	newBoard = BOARD.instantiate()
	add_child(newBoard)
	newBoard.visible = false
	newHostSetup = HOST_SETUP.instantiate()
	add_child(newHostSetup)
	newHostSetup.visible = true
	

@rpc("any_peer","call_remote","reliable")
func nameChangeReceived(requestedName):
	var sender_id = multiplayer.get_remote_sender_id()
	if requestedName not in id_dictionary.values():
		id_dictionary[sender_id] = requestedName
		rpc_id(sender_id, "replyNameChange",true)
	else:
		rpc_id(sender_id, "replyNameChange",false)
	newHostSetup.updateNames(id_dictionary)

@rpc("any_peer","call_remote","reliable")
func unreadyReceived():
	var sender_id = multiplayer.get_remote_sender_id()
	if playerHostID == sender_id:
		playerHostID = -1
		rpc_id(sender_id, "replyUnready",true)
		rpc("hostUnready")
		return
	elif id_dictionary.has(sender_id):
		id_dictionary.erase(sender_id)
		newHostSetup.updateNames(id_dictionary)
		rpc_id(sender_id, "replyUnready",true)
		return
	else:
		push_error("unready received by host, but no player found!")
		rpc_id(sender_id, "replyUnready",false)
		
@rpc("any_peer","call_remote","reliable")
func hostReceived():
	var sender_id = multiplayer.get_remote_sender_id()
	if playerHostID == -1:
		playerHostID = sender_id
		rpc_id(sender_id, "replyHost",true)
	else:
		push_error("someone requested host even with an already chosen host?!")
		rpc_id(sender_id, "replyHost",false)
	rpc("hostReady")
#endregion

#region Client
var createNameSet : clientSetup
func confirmClientConnection():
	print("clinet connected!")
	createNameSet = CLIENT_SETUP.instantiate()
	add_child(createNameSet)
	createNameSet.changeName.connect(requestNameChange)
	createNameSet.unready.connect(requestUnready)
	createNameSet.selectedHost.connect(requestHost)

## Requests
func requestNameChange(requestedName):
	rpc_id(1,"nameChangeReceived",requestedName)

func requestUnready():
	rpc_id(1, "unreadyReceived")

func requestHost():
	rpc_id(1, "hostReceived")

## Replies
@rpc("authority","call_remote","reliable")
func replyNameChange(worked : bool):
	createNameSet.replyNameChange(worked)

@rpc("authority","call_remote","reliable")
func replyUnready(worked : bool):
	createNameSet.replyUnready(worked)

@rpc("authority","call_remote","reliable")
func replyHost(worked : bool):
	createNameSet.replyHost(worked)

## Extras
@rpc("any_peer","call_remote","reliable")
func hostReady():
	createNameSet.hostReady()

@rpc("any_peer","call_remote","reliable")
func hostUnready():
	createNameSet.hostUnready()
#endregion
