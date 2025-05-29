extends CanvasLayer
class_name clientSetup

signal changeName
signal selectedHost
signal unready
signal startGame

var host : bool


@onready var h_box_options = $hBoxOptions
@onready var splitter = $hBoxOptions/splitter
## Host nodes
@onready var host_options = $hBoxOptions/hostOptions
## Player nodes
@onready var name_input = $hBoxOptions/settingName/nameInput
@onready var name_feedback = $hBoxOptions/settingName/nameFeedback
## Allset Nodes
@onready var all_set = $allSet
@onready var un_ready = $allSet/unReady
@onready var error_ = $"allSet/Error!"
@onready var start_game = $allSet/startGame


func _ready():
	host = false
	name_feedback.visible = false
	error_.visible = false
	h_box_options.visible = true
	all_set.visible = false
	start_game.visible = false
	splitter.visible = true
	host_options.visible = true
#region Outgoing
func confirm_name_button() -> void:
	if name_input.text.length() > 0:
		changeName.emit(name_input.text)

func unready_button():
	unready.emit()

func host_button():
	selectedHost.emit()
	
func start_game_button():
	startGame.emit()
#endregion


#region Incoming
func replyNameChange(check : bool):
	name_feedback.visible = true
	if check:
		h_box_options.visible = false
		all_set.visible = true
	else:
		name_feedback.texture.region.position.x = 50

func replyUnready(check : bool):
	if check:
		host = false
		h_box_options.visible = true
		all_set.visible = false
		start_game.visible = false
		error_.visible = false
	else:
		error_.text = "If you're seeing this, some very strange error occured. I don't think this error can actually happen but this is a safe guard incase it does! I'll keep you as \"All set,\" but feel free to reset the program if you need to unready (so sorry lol)"
		error_.visible = true
		
func replyHost(check : bool):
	if check:
		host = true
		h_box_options.visible = false
		all_set.visible = true
		start_game.visible = true
	else:
		pass

func replyStartGame(check : int):
	if check == -1:
		error_.text = "The system swears there is no host, but if you pressed that button than you should be a host? I don't think that can happen, but this is an error message that will pop up incase that happens. Try resetting?"
		error_.visible = true
	if check > 0:
		if check == 1:
			error_.text = "There is " + str(check) + " player who has connected, but haven't chosen a name"
		else:
			error_.text = "There are " + str(check) + " players who are connected, but haven't chosen a name"
		error_.visible = true
	if check == 0:
		pass
		
func hostReady():
	host_options.visible = false
	splitter.visible = false
func hostUnready():
	host_options.visible = true
	splitter.visible = true
#endregion
