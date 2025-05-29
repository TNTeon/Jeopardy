extends CanvasLayer
class_name playerScreen

signal buzzedIn

@onready var name_text = $nameText
@onready var money_display = $moneyDisplay
@onready var buzz_button_ref : Button = $buzzButton

func _ready():
	buzz_button_ref.visible = false

## Outgoing
func buzz_button():
	buzz_button_ref.release_focus()
	buzzedIn.emit()

## Incoming
func allowBuzzing(pastBuzzers):
	if name_text.text not in pastBuzzers:
		buzz_button_ref.visible = true
func stopBuzzing():
	buzz_button_ref.visible = false

func changePoints(points):
	money_display.text = "$"+str(int(money_display.text.replace("$","")) + points)
