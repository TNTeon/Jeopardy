extends Node

const CLIENT_SETUP = preload("res://Classes/Networking/Clinet/Setup/clientSetup.tscn")
const HOST_SETUP = preload("res://Classes/Networking/Host/hostSetup.tscn")
const BOARD = preload("res://Classes/Board/Board.tscn")
const PLAYER_SCREEN = preload("res://Classes/Networking/Clinet/playerScreen/playerScreen.tscn")
const HOST_SCREEN = preload("res://Classes/Networking/Clinet/hostScreen/hostScreen.tscn")

@onready var function: RichTextLabel = $Function
@export var host : bool = true

var port = 9105
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
	newBoard.allowBuzzing.connect(
		func(pastBuzz):
			pastBuzz.filter(func(n): return id_dictionary.find_key(n))
			rpc("allowBuzzingClients",pastBuzz)
	)
	newBoard.stopBuzzing.connect(func(): rpc("stopBuzzingClients"))
	newBoard.newTile.connect(
		func(tile : QuestionTile):
			var serialize = {}
			serialize["question"] = tile.question
			serialize["answer"] = tile.answer
			serialize["pointValue"] = tile.point_value
			rpc_id(playerHostID,"newTile",serialize)
	)
	newBoard.changePlayerPoints.connect(changePoints)
	newHostSetup = HOST_SETUP.instantiate()
	add_child(newHostSetup)
	newHostSetup.visible = true
	
func changePoints(plrName, points):
	var playerId = id_dictionary.find_key(plrName)
	rpc_id(playerId,"changePointsClient", points)
	
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
		newHostSetup.host_text.text = "No Host"
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
		newHostSetup.host_text.text = "Host Selected"
		rpc_id(sender_id, "replyHost",true)
	else:
		push_error("someone requested host even with an already chosen host?!")
		rpc_id(sender_id, "replyHost",false)
	rpc("hostReady")
	
@rpc("any_peer","call_remote","reliable")
func startGameReceived():
	var sender_id = multiplayer.get_remote_sender_id()
	var numOfPlayers = len(multiplayer.get_peers())
	if playerHostID == -1:
		rpc_id(sender_id,"replyStartGame",-1)
		return
	if len(id_dictionary.keys()) < numOfPlayers - 1: # - 1 because of host
		rpc_id(sender_id,"replyStartGame",numOfPlayers-1-len(id_dictionary.keys()))
		return
	newBoard.visible = true
	newHostSetup.visible = false
	rpc_id(sender_id,"replyStartGame",0)
	rpc("startingGame")

@rpc("any_peer","call_remote","reliable")
func buzzReceived():
	var sender_id = multiplayer.get_remote_sender_id()
	if newBoard.selectedTile:
		var sender_name = id_dictionary[sender_id]
		newBoard.selectedTile.plrBuzzes(sender_name)
#endregion

#region Client
var createClientSetup : clientSetup
var createClientScreen : playerScreen
var createHostScreen : hostScreen
func confirmClientConnection():
	print("clinet connected!")
	createClientSetup = CLIENT_SETUP.instantiate()
	add_child(createClientSetup)
	createClientSetup.changeName.connect(requestNameChange)
	createClientSetup.unready.connect(requestUnready)
	createClientSetup.selectedHost.connect(requestHost)
	createClientSetup.startGame.connect(requestStartGame)

@rpc("any_peer","call_remote","reliable")
func startingGame():
	if createClientSetup.host:
		createHostScreen = HOST_SCREEN.instantiate()
		add_child(createHostScreen)
	else:
		createClientScreen = PLAYER_SCREEN.instantiate()
		add_child(createClientScreen)
		createClientScreen.name_text.text = createClientSetup.name_input.text
		createClientScreen.buzzedIn.connect(requestBuzz)
	createClientSetup.queue_free()

## Requests
func requestNameChange(requestedName):
	rpc_id(1,"nameChangeReceived",requestedName)

func requestUnready():
	rpc_id(1, "unreadyReceived")

func requestHost():
	rpc_id(1, "hostReceived")
	
func requestStartGame():
	rpc_id(1, "startGameReceived")
	
func requestBuzz():
	rpc_id(1,"buzzReceived")

## Replies
@rpc("authority","call_remote","reliable")
func replyNameChange(worked : bool):
	createClientSetup.replyNameChange(worked)

@rpc("authority","call_remote","reliable")
func replyUnready(worked : bool):
	createClientSetup.replyUnready(worked)

@rpc("authority","call_remote","reliable")
func replyHost(worked : bool):
	createClientSetup.replyHost(worked)

@rpc("authority","call_remote","reliable")
func replyStartGame(worked : int):
	createClientSetup.replyStartGame(worked)

## Extras
@rpc("any_peer","call_remote","reliable")
func hostReady():
	createClientSetup.hostReady()

@rpc("any_peer","call_remote","reliable")
func hostUnready():
	createClientSetup.hostUnready()

@rpc("any_peer","call_remote","reliable")
func allowBuzzingClients(pastBuzzers):
	if createClientScreen:
		createClientScreen.allowBuzzing(pastBuzzers)

@rpc("any_peer","call_remote","reliable")
func stopBuzzingClients():
	if createClientScreen:
		createClientScreen.stopBuzzing()
		
@rpc("authority","call_remote","reliable")
func changePointsClient(points : int):
	createClientScreen.changePoints(points)

@rpc("authority","call_remote","reliable")
func newTile(question : Dictionary):
	createHostScreen.newTile(question)

#endregion
