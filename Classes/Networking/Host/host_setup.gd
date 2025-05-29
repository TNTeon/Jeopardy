extends CanvasLayer
class_name hostSetup

@onready var store_player_names = $storePlayerNames
const NAME = preload("res://Classes/Networking/Host/name.tscn")

func updateNames(players : Dictionary):
	var includedNames = []
	for plrLabel in store_player_names.get_children():
		if plrLabel.name not in players.values():
			plrLabel.queue_free()
		else:
			includedNames.append(plrLabel.name)
	for desiredName in players.values():
		if desiredName not in includedNames:
			var newName : RichTextLabel = NAME.instantiate()
			newName.text = "• "+desiredName
			store_player_names.add_child(newName)
