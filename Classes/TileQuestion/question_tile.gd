extends Control
class_name QuestionTile

@export var point_value : int = 100
@export var question : String = ""

@onready var tile : Panel = $Tile
@onready var score : RichTextLabel = $Tile/Score

@onready var question_canvas = $QuestionCanvas
@onready var question_box = $QuestionCanvas/VSplitContainer
@onready var button = $Tile/Button

func _ready():
	score.text = "[b]"+str(point_value)
	question_canvas.visible = true
	question_box.scale = Vector2.ZERO

func initialize(pv : int, qu : String):
	point_value = pv
	question = qu

func tile_clicked():
	print("pressed")
	button.release_focus()
	
	#Animate
	tile.set_meta("midpoint",tile.position+tile.size/2)
	question_box.global_position = tile.get_meta("midpoint")+tile.global_position
	var tween = create_tween()
	tween.parallel().tween_property(question_box,"scale",Vector2.ONE,0.5)
	tween.parallel().tween_property(question_box,"position",Vector2.ZERO,0.5)
