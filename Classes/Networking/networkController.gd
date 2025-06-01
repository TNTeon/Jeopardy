extends Node

const CLIENT_SETUP = preload("res://Classes/Networking/Clinet/Setup/clientSetup.tscn")
const HOST_SETUP = preload("res://Classes/Networking/Host/hostSetup.tscn")
const BOARD = preload("res://Classes/Board/Board.tscn")
const PLAYER_SCREEN = preload("res://Classes/Networking/Clinet/playerScreen/playerScreen.tscn")
const HOST_SCREEN = preload("res://Classes/Networking/Clinet/hostScreen/hostScreen.tscn")
const CONNECT_TO_SERVER = preload("res://Classes/Networking/Clinet/connectToServer/connectToServer.tscn")
const PLAYER_ICON = preload("res://Classes/PlayerIcon/PlayerIcon.tscn")

@export var host : bool = false

var port = 9105
var multiplayer_peer = ENetMultiplayerPeer.new()

var name_dictionary = {}
var score_dictionary = {}
var ip_dictionary = {}
var icon_dictionary = {}
var playerHostID : int = -1
var disconnectedIDs = []

var newConnectionScene

var currentServerState : serverStates

enum serverStates{
	PRE_GAME,
	GAME_STARTED
}

signal updatedServerState
signal updatedIps

func _ready():
	host = TransferInformation.isHost
	if !host:
		newConnectionScene = CONNECT_TO_SERVER.instantiate()
		add_child(newConnectionScene)
		newConnectionScene.attemptConnection.connect(requestConnection)
	else:
		multiplayer_peer.create_server(port)
		multiplayer.multiplayer_peer = multiplayer_peer
		multiplayer.peer_disconnected.connect(disconnectedPeer)
		serverCreated()

func requestConnection(ip):
	ip = ip.replace("Z","GOHDGLND")
	ip = ip.replace("Y","GFD")
	ip = ip.replace("X","GMHD")
	for i in range(ip.length()):
		var uni = ip.unicode_at(i)
		ip[i] = String.chr(uni - 22)
	var error = multiplayer_peer.create_client(ip,port)
	if error == OK:
		print("connecting")
		multiplayer.multiplayer_peer = multiplayer_peer
		multiplayer.connected_to_server.connect(confirmClientConnection)
		multiplayer.server_disconnected.connect(func():get_tree().reload_current_scene())
	else:
		print("Connection failed: ",ip)
		newConnectionScene.failed()
		multiplayer_peer.close()

#region Host
var newBoard : board
var newHostSetup : hostSetup

func serverCreated():
	currentServerState = serverStates.PRE_GAME
	newBoard = BOARD.instantiate()
	add_child(newBoard)
	newBoard.visible = false
	newBoard.allowBuzzing.connect(
		func(pastBuzz):
			pastBuzz.filter(func(n): return name_dictionary.find_key(n))
			rpc("allowBuzzingClients",pastBuzz)
	)
	newBoard.stopBuzzing.connect(func(): rpc("stopBuzzingClients"))
	newBoard.newTile.connect(
		func(tile : QuestionTile):
			var serialize = {}
			serialize["question"] = tile.question
			serialize["answer"] = tile.answer
			serialize["pointValue"] = tile.point_value
			tile.signalOutOfPlayers.connect(func():rpc_id(playerHostID,"tellHostOutOfPlayers"))
			rpc_id(playerHostID,"newTile",serialize)
	)
	newBoard.changePlayerPoints.connect(changePoints)
	newHostSetup = HOST_SETUP.instantiate()
	add_child(newHostSetup)
	newHostSetup.visible = true
	
func changePoints(plrName, points):
	var playerId = name_dictionary.find_key(plrName)
	score_dictionary[playerId] += points
	icon_dictionary[playerId].addToScore(points)
	rpc_id(playerId,"changePointsClient", points)
	
func disconnectedPeer(peerID):
	print(str(peerID) + " disconnected")
	if ip_dictionary.has(peerID):
		print("with ip: ", ip_dictionary[peerID])
	if currentServerState == serverStates.PRE_GAME:
		name_dictionary.erase(peerID)
		ip_dictionary.erase(peerID)
		score_dictionary.erase(peerID)
	elif name_dictionary.has(peerID):
		disconnectedIDs.append(peerID)
	
@rpc("any_peer","call_remote","reliable")
func nameChangeReceived(requestedName):
	var sender_id = multiplayer.get_remote_sender_id()
	if requestedName not in name_dictionary.values():
		var newPlayerIcon = PLAYER_ICON.instantiate()
		newBoard.store_icons.add_child(newPlayerIcon)
		newPlayerIcon.updateName(requestedName)
		newPlayerIcon.updateScore(0)
		
		name_dictionary[sender_id] = requestedName
		ip_dictionary[sender_id] = multiplayer_peer.get_peer(sender_id).get_remote_address()
		score_dictionary[sender_id] = 0
		icon_dictionary[sender_id] = newPlayerIcon
		rpc_id(sender_id, "replyNameChange",true)
	else:
		rpc_id(sender_id, "replyNameChange",false)
	newHostSetup.updateNames(name_dictionary)

@rpc("any_peer","call_remote","reliable")
func unreadyReceived():
	var sender_id = multiplayer.get_remote_sender_id()
	if playerHostID == sender_id:
		playerHostID = -1
		newHostSetup.host_text.text = "No Host"
		rpc_id(sender_id, "replyUnready",true)
		rpc("hostUnready")
		return
	elif name_dictionary.has(sender_id):
		icon_dictionary[sender_id].queue_free()
		icon_dictionary.erase(sender_id)
		name_dictionary.erase(sender_id)
		ip_dictionary.erase(sender_id)
		newHostSetup.updateNames(name_dictionary)
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
	if len(name_dictionary.keys()) < numOfPlayers - 1: # - 1 because of host
		rpc_id(sender_id,"replyStartGame",numOfPlayers-1-len(name_dictionary.keys()))
		return
	newBoard.visible = true
	newHostSetup.visible = false
	var sendCategoryList = serializeCategoryList(newBoard.categoryList)
	rpc_id(sender_id,"replyStartGame",0)
	rpc("startingGame")
	rpc_id(sender_id,"giveHostCategories",sendCategoryList)
	currentServerState = serverStates.GAME_STARTED

@rpc("any_peer","call_remote","reliable")
func buzzReceived():
	var sender_id = multiplayer.get_remote_sender_id()
	if newBoard.selectedTile:
		var sender_name = name_dictionary[sender_id]
		newBoard.selectedTile.plrBuzzes(sender_name)
		rpc_id(playerHostID,"tellHostPlrBuzzed")
		
@rpc("any_peer","call_remote","reliable")
func reconnectPlayer(oldID):
	var sender_id = multiplayer.get_remote_sender_id()
	print("old id is ",oldID)
	print("is it in ",disconnectedIDs)
	if oldID in disconnectedIDs:
		disconnectedIDs.erase(oldID)
		name_dictionary[sender_id] = name_dictionary[oldID]
		ip_dictionary[sender_id] = ip_dictionary[oldID]
		score_dictionary[sender_id] = score_dictionary[oldID]
		icon_dictionary[sender_id] = icon_dictionary[oldID]
		name_dictionary.erase(oldID)
		ip_dictionary.erase(oldID)
		score_dictionary.erase(oldID)
		icon_dictionary.erase(oldID)
		rpc_id(sender_id, "replyReconnectPlayer",oldID)
		rpc_id(sender_id, "replyDictionaries",name_dictionary, ip_dictionary, score_dictionary)
	else:
		rpc_id(sender_id, "replyReconnectPlayer", -1)

@rpc("any_peer","call_remote","reliable")
func requestCurrentState():
	var sender_id = multiplayer.get_remote_sender_id()
	print("request Info from: ", multiplayer_peer.get_peer(sender_id).get_remote_address())
	print("compare to ip's: ", disconnectedIDs, "\n")
	rpc_id(sender_id, "replyCurrentState",currentServerState)

@rpc("any_peer","call_remote","reliable")
func requestDictionaries():
	var sender_id = multiplayer.get_remote_sender_id()
	rpc_id(sender_id, "replyDictionaries",name_dictionary, ip_dictionary, score_dictionary)

@rpc("any_peer","call_remote","reliable")
func selectTileOnBoard(first,second):
	newBoard.selectTile(first,second)

@rpc("any_peer","call_remote","reliable")
func hostMovingOn():
	newBoard.selectedTile.hostMovingOn()

@rpc("any_peer","call_remote","reliable")
func hostRated(rating):
	newBoard.selectedTile.hostRated(rating)

@rpc("any_peer","call_remote","reliable")
func printToServer(info):
	print("MESSAGE FROM CLIENT")
	print(info)
#endregion

#region Client
var createClientSetup : clientSetup
var createClientScreen : playerScreen
var createHostScreen : hostScreen
func confirmClientConnection():
	rpc_id(1, "requestCurrentState")
	await updatedServerState
	if currentServerState == serverStates.PRE_GAME:
		createClientSetup = CLIENT_SETUP.instantiate()
		add_child(createClientSetup)
		createClientSetup.changeName.connect(requestNameChange)
		createClientSetup.unready.connect(requestUnready)
		createClientSetup.selectedHost.connect(requestHost)
		createClientSetup.startGame.connect(requestStartGame)
		newConnectionScene.queue_free()
	else:
		rpc_id(1, "requestDictionaries")
		await updatedIps
		rpc_id(1, "printToServer",ip_dictionary)
		var clientIP = findLocalIP()
		if clientIP in ip_dictionary.values():
			var clientID = ip_dictionary.find_key(clientIP)
			var clientName = name_dictionary[clientID]
			rpc_id(1,"reconnectPlayer",clientID)
		else:
			newConnectionScene.gameAlreadyStarted()
			multiplayer_peer.close()

@rpc("any_peer","call_remote","reliable")
func startingGame():
	if createClientSetup.host:
		createHostScreen = HOST_SCREEN.instantiate()
		add_child(createHostScreen)
		createHostScreen.tileSelected.connect(func(first,second):rpc_id(1,"selectTileOnBoard",first,second))
		createHostScreen.moveOnSignal.connect(func():rpc_id(1,"hostMovingOn"))
		createHostScreen.rating.connect(func(rate):rpc_id(1,"hostRated",rate))
	else:
		createCilentScreen(createClientSetup.name_input.text)
	createClientSetup.queue_free()

@rpc("authority","call_remote","reliable")
func giveHostCategories(categories : Array[Dictionary]):
	createHostScreen.fillCategories(categories)

func createCilentScreen(nameForClient):
	createClientScreen = PLAYER_SCREEN.instantiate()
	add_child(createClientScreen)
	createClientScreen.name_text.text = nameForClient
	createClientScreen.buzzedIn.connect(requestBuzz)

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
func replyCurrentState(currState : serverStates):
	currentServerState = currState
	updatedServerState.emit()

@rpc("authority","call_remote","reliable")
func replyDictionaries(names : Dictionary,ipAddresses : Dictionary, scores):
	name_dictionary = names
	ip_dictionary = ipAddresses
	score_dictionary = scores
	updatedIps.emit()

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

@rpc("authority","call_remote","reliable")
func replyReconnectPlayer(worked : int):
	if worked == -1:
		multiplayer_peer.close()
		newConnectionScene.gameAlreadyStarted()
		push_error("never disconnected!")
	else:
		createCilentScreen(name_dictionary[worked])
		await updatedIps
		createClientScreen.changePoints(score_dictionary[multiplayer.get_unique_id()])

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
func tellHostPlrBuzzed():
	createHostScreen.changeStates(createHostScreen.states.GRADING_RESPONSE)

@rpc("authority","call_remote","reliable")
func tellHostOutOfPlayers():
	createHostScreen.changeStates(createHostScreen.states.TILE_DYING)

@rpc("authority","call_remote","reliable")
func changePointsClient(points : int):
	createClientScreen.changePoints(points)

@rpc("authority","call_remote","reliable")
func newTile(question : Dictionary):
	createHostScreen.newTile(question)

#endregion

func serializeCategoryList(resourceArray : Array[categoryResource]):
	var serialized : Array[Dictionary]
	for i in resourceArray:
		var newCatDict = {}
		newCatDict["title"] = i.title
		for j in range(len(i.questionTile)):
			var newTileDict = {}
			newTileDict["pointValue"] = i.questionTile[j].pointValue
			newTileDict["Answer"] = i.questionTile[j].Answer
			newTileDict["Question"] = i.questionTile[j].Question
			newCatDict[j] = newTileDict
		serialized.append(newCatDict)
	return serialized

func findLocalIP() -> String:
	var ip = ""
	for address in IP.get_local_addresses():
		if "." in address and not address.begins_with("127.") and not address.begins_with("169.254."):
			if address.begins_with("192.168.") or address.begins_with("10.") or (address.begins_with("172.") and int(address.split(".")[1]) >= 16 and int(address.split(".")[1]) <= 31):
				print(address.split(".")[1])
				ip = address
				break
	return ip
