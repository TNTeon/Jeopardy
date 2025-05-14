extends Control
class_name QuestionTile
## QuestionTile
##
##--Description--
## A tile for a single question. Click the tile to open the clue and play the tile.
## Disapears after use
##
##--Use--
## The tile will take up as much space as possible. Limit it by putting it into a control node
##	with a set size

## --Important-Functions--
##
## initialize(pv, qu)
##	Description: Use when exported variables aren't set
##	pv: point value of the question
##	qu: quesiton
##
## plrBuzzes(name)
##	Description: Adds the player who buzzed to a queue. Deals with the lastest player
##	name: name of the player who buzzed (This will be displayed)
##
## correctAnswer()
##	Description: Counts the question as correct and stops any new buzzes
##
## incorrectAnswer()
##	Description: Counts the players response as wrong and allows new answers

#region Variables
@export var point_value : int = 100
@export var question : String = ""
@export var answer : String = ""

#region References
@onready var tile : Panel = $Tile
@onready var score : RichTextLabel = $Tile/Score

@onready var _question_canvas = $QuestionCanvas
@onready var _question_text = $QuestionCanvas/Background/VSplit/QuestionBox/QuestionText
@onready var _background = $QuestionCanvas/Background
@onready var _button = $Tile/Button
@onready var _buzzerPanel = $QuestionCanvas/Background/VSplit/Buzzer
@onready var _pointsPanel = $QuestionCanvas/Background/VSplit/Points
@onready var _extra_point_panel = $QuestionCanvas/Background/VSplit/Points/PointsText
@onready var _nameText = $QuestionCanvas/Background/VSplit/Buzzer/Name
@onready var _gradient = $QuestionCanvas/Background/VSplit/Buzzer/Timer/Gradient

@onready var _timer = $QuestionCanvas/Timer
@onready var _time_out_sound = $QuestionCanvas/Timer/timeOutSound
#endregion

enum state{
	IDLE,
	VIEWING,
	WAITING,
	ANSWERING,
	JUDGEMENT,
	ANSWERED
}
var currState = state.IDLE
var buzzers = []
var pastBuzzers = []
#endregion

#region CreatedFunctions
func initialize(pv : int, qu : String, an : String):
	point_value = pv
	question = qu
	answer = an
	
	_extra_point_panel.text = "[b]"+str(point_value)
	score.text = "[b]"+str(point_value)
	point_value
	
	_question_text.text = question
	
	_background.scale = Vector2.ZERO
	_question_canvas.visible = true
	_buzzerPanel.visible = false
	_pointsPanel.visible = false

func tile_clicked():
	currState = state.VIEWING
	_button.release_focus()
	
	#Animate
	tile.set_meta("midpoint",tile.position+tile.size/2)
	_background.global_position = tile.get_meta("midpoint")+tile.global_position
	var tween = create_tween()
	tween.parallel().tween_property(_background,"scale",Vector2.ONE,0.5)
	tween.parallel().tween_property(_background,"position",Vector2.ZERO,0.5)
	
func startTimer():
	_timer.start(5)
	#TODO just make the question answered if no players left
	if currState == state.VIEWING:
		currState = state.WAITING
		_pointsPanel.visible = true
	
func plrBuzzes(name):
	if !buzzers.has(name) and !pastBuzzers.has(name):
		_buzzerPanel.visible = true
		buzzers.append(name)
		if !_timer.is_stopped():
			waitForAnswer()

func waitForAnswer():
	currState = state.ANSWERING
	var currentPlr = buzzers[0]
	pastBuzzers.append(currentPlr)
	buzzers.pop_front()
	_nameText.text = currentPlr
	startTimer()
	
func closeQuestion():
	#Animate
	_button.visible = false
	score.visible = false
	var tween = create_tween()
	tween.parallel().tween_property(_background,"scale",Vector2.ZERO,0.5)
	tween.parallel().tween_property(_background,"position",tile.get_meta("midpoint")+tile.global_position,0.5)

func correctAnswer():
	#TODO Add points to player
	_timer.paused = true
	currState = state.ANSWERED
	
func incorrectAnswer():
	#TODO Remove points from player
	_buzzerPanel.visible = false
	currState = state.VIEWING
	startTimer()

func timer_up():
	_time_out_sound.play()
	if currState == state.WAITING:
		currState = state.ANSWERED
	if currState == state.ANSWERING:
		currState = state.JUDGEMENT
#endregion

#region BaseFunctions

func _ready():
	if point_value != -1:
		initialize(point_value,question,answer)
	
func _process(delta):
	#Shink the timer when answering
	if !_timer.is_stopped() and currState == state.ANSWERING:
		_gradient.scale.x = _timer.time_left/5
	
	#TODO Change temp input actions to real ones.
	#Allow Answering
	if Input.is_action_just_pressed("ui_accept") and currState == state.VIEWING:
		startTimer()
	#Move forward after answering (might want to add answer after this?!)
	elif Input.is_action_just_pressed("ui_accept") and currState == state.ANSWERED:
		closeQuestion()
	
	#Allows judge for correct and incorrect answers
	if Input.is_action_just_pressed("ui_up") and (currState == state.ANSWERING or currState == state.JUDGEMENT):
		correctAnswer()
	if Input.is_action_just_pressed("ui_down") and (currState == state.ANSWERING or currState == state.JUDGEMENT):
		incorrectAnswer()
	
	#FIXME Allow players to buzz in properly and remove this temp fix
	if Input.is_action_just_pressed("ui_left") and currState == state.WAITING:
		plrBuzzes("Teon")
	if Input.is_action_just_pressed("ui_right") and currState == state.WAITING:
		plrBuzzes("Boen")
#endregion
