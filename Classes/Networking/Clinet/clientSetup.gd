extends CanvasLayer
class_name clientSetup

signal changeName
signal selectedHost
signal unready


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


func _ready():
	name_feedback.visible = false
	error_.visible = false

#region Outgoing
func confirm_name_button() -> void:
	if name_input.text.length() > 0:
		changeName.emit(name_input.text)

func unready_button():
	unready.emit()

func host_button():
	selectedHost.emit()
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
		h_box_options.visible = true
		all_set.visible = false
	else:
		error_.visible = true
		
func replyHost(check : bool):
	if check:
		h_box_options.visible = false
		all_set.visible = true
	else:
		pass
		
func hostReady():
	host_options.visible = false
	splitter.visible = false
func hostUnready():
	host_options.visible = true
	splitter.visible = true
#endregion
