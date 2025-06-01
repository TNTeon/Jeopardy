extends CanvasLayer
class_name hostScreen

var categoryList : Array[Dictionary]
const SELECTABLE_HOST_TILE = preload("res://Classes/Networking/Clinet/hostScreen/selectableHostTile/selectableHostTile.tscn")

signal tileSelected
signal moveOnSignal
signal rating

##TileClicked
@onready var tile_clicked: Control = $TileClicked
@onready var display_question: RichTextLabel = $TileClicked/QuestionPanel/displayQuestion
@onready var display_answer: RichTextLabel = $TileClicked/AnswerPanel/displayAnswer
@onready var display_pv: scaleableText = $TileClicked/PointPanel/displayPV
@onready var start_buzzing: Button = $TileClicked/startBuzzing
@onready var end_question_but: Button = $TileClicked/EndQuestion

##selectCategory
@onready var select_category: Control = $selectCategory
@onready var store_category: HBoxContainer = $selectCategory/storeCategory
##SelectTile
@onready var select_tile: Control = $selectTile
@onready var display_category: scaleableText = $selectTile/displayCategory
@onready var store_tile: VBoxContainer = $selectTile/storeTile
##gradingResponse
@onready var store_ratings: VBoxContainer = $TileClicked/RatePanel/storeRatings
@onready var up_arrow: TextureButton = $TileClicked/RatePanel/storeRatings/upArrow
@onready var down_arrow: TextureButton = $TileClicked/RatePanel/storeRatings/downArrow

var pastUsedTile = []

enum states{
	SELECTING_CATEGORY,
	SELECTING_TILE,
	READING_TILE,
	GRADING_RESPONSE,
	TILE_DYING
}

var currState = states.SELECTING_CATEGORY

func _ready():
	display_question.text = ""
	display_answer.text = ""
	display_pv.text = ""
	changeStates(states.SELECTING_CATEGORY)

func changeStates(newState : states):
	currState = newState
	match newState:
		states.READING_TILE:
			readTileEnter()
		states.SELECTING_CATEGORY:
			selectCategoryEnter()
		#states.SELECTING_TILE:
		states.GRADING_RESPONSE:
			gradeResponseEnter()
		states.TILE_DYING:
			tileDyingEnter()

##TileClicked
func readTileEnter():
	tile_clicked.visible = true
	select_category.visible = false
	select_tile.visible = false
	start_buzzing.visible = true
	store_ratings.visible = false
	end_question_but.visible = false
func newTile(tile : Dictionary):
	display_question.text = tile["question"]
	display_answer.text = tile["answer"]
	display_pv.text = "[b]$"+str(tile["pointValue"])
func _on_start_buzzing_pressed() -> void:
	start_buzzing.visible = false
	moveOnSignal.emit()
func gradeResponseEnter():
	store_ratings.visible = true
func rateGood() -> void:
	store_ratings.visible = false
	rating.emit(true)
	changeStates(states.TILE_DYING)
func rateBad() -> void:
	store_ratings.visible = false
	rating.emit(false)

##selectCategory
func fillCategories(givenCategoryList : Array[Dictionary]):
	categoryList = givenCategoryList
	for i in categoryList:
		var newCategorySelectable = SELECTABLE_HOST_TILE.instantiate()
		store_category.add_child(newCategorySelectable)
		newCategorySelectable.text = i["title"]
		newCategorySelectable.selected.connect(catSelected)
func selectCategoryEnter():
	tile_clicked.visible = false
	select_category.visible = true
	select_tile.visible = false
func catSelected(nameOfCat):
	for i in range(len(categoryList)):
		if categoryList[i]["title"] == nameOfCat:
			selectTileEnter(i)
			return

##SelectTile
func selectTileEnter(numberOfCat):
	changeStates(states.SELECTING_TILE)
	tile_clicked.visible = false
	select_category.visible = false
	select_tile.visible = true
	display_category.text = categoryList[numberOfCat]["title"]
	for child in store_tile.get_children():
		child.queue_free()
	var count = 0
	while categoryList[numberOfCat].has(count):
		var currentTile = categoryList[numberOfCat][count]
		var newTileSelectable = SELECTABLE_HOST_TILE.instantiate()
		newTileSelectable.whiteTheme = false
		store_tile.add_child(newTileSelectable)
		newTileSelectable.text = "$" + str(currentTile["pointValue"])
		newTileSelectable.selected.connect(
			func(extra):
				if [numberOfCat,count] not in pastUsedTile:
					pastUsedTile.append([numberOfCat,count])
					tileSelected.emit(numberOfCat,count)
					changeStates(states.READING_TILE)
		)
		count += 1
func _on_back_to_categories_pressed() -> void:
	changeStates(states.SELECTING_CATEGORY)

func tileDyingEnter():
	end_question_but.visible = true
func end_question() -> void:
	moveOnSignal.emit()
	changeStates(states.SELECTING_CATEGORY)
