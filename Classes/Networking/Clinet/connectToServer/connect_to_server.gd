extends CanvasLayer

signal attemptConnection

@onready var input_code = $inputCode
@onready var join_feedback_img = $joinFeedbackImg
@onready var join_feedback_text = $joinFeedbackText
@onready var join_button = $joinButton

func _ready():
	join_feedback_text.visible = false
	join_feedback_img.visible = false

func connectionButton():
	join_button.release_focus()
	attemptConnection.emit(input_code.text.to_upper())

func failed():
	join_feedback_text.visible = true
	join_feedback_img.visible = true
	join_feedback_text.text = "Connection to server failed\nEnsure you are connected to the same network as the hosted computer and your code is correct"

func gameAlreadyStarted():
	join_feedback_text.visible = true
	join_feedback_img.visible = true
	join_feedback_text.text = "The game has alreay started"
