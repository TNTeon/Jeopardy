extends Control
class_name EditableTile

var selfResource = tileResource.new()

@export var point_value : int = 100
@export var question : String = ""
@export var answer : String = ""

@onready var tile : Panel = $Tile
@onready var score : RichTextLabel = $Tile/Score
@onready var _question_canvas = $QuestionCanvas
@onready var _question_text = $QuestionCanvas/Background/VSplit/QuestionBox/QuestionText
@onready var _background = $QuestionCanvas/Background
@onready var _buzzerPanel = $QuestionCanvas/Background/VSplit/Buzzer
@onready var _pointsPanel = $QuestionCanvas/Background/VSplit/Points
@onready var _extra_point_panel = $QuestionCanvas/Background/VSplit/Points/PointsText

var EditablePlayable
signal selected

func update(pv : int, qu : String, an : String):
	point_value = pv
	question = qu
	answer = an
	
	_extra_point_panel.text = "[b]"+str(point_value)
	score.text = "[b]$"+str(point_value)
	_question_text.text = question
	
	selfResource.Answer = answer
	selfResource.pointValue = point_value
	selfResource.Question = question

func initialize(pv : int, qu : String, an : String, base : Control):
	update(pv, qu, an)
	
	_background.scale = Vector2.ZERO
	_question_canvas.visible = true
	_buzzerPanel.visible = false
	_pointsPanel.visible = false
	
	selected.connect(base.newSelection)
	base.removeSelections.connect(clearSelection)
	EditablePlayable = base


func _ready():
	if point_value != -1:
		initialize(point_value,question,answer, EditablePlayable)


func _on_button_pressed() -> void:
	selected.emit(self)
	var new_stylebox_normal = tile.get_theme_stylebox("panel").duplicate()
	new_stylebox_normal.border_color = Color.DARK_BLUE
	tile.add_theme_stylebox_override("panel", new_stylebox_normal)
	
func clearSelection():
	tile.remove_theme_stylebox_override("panel")
