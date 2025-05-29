extends CanvasLayer
class_name hostSetup

@onready var host_text = $HostText
@onready var store_player_names = $storePlayerNames
const NAME = preload("res://Classes/Networking/Host/name.tscn")

func _ready():
	print(findLocalIP())
	print()

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

func findLocalIP():
	var ip_address : String
	if OS.has_feature("windows"):
		if OS.has_environment("COMPUTERNAME"):
			ip_address =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),1)
	elif OS.has_feature("x11"):
		if OS.has_environment("HOSTNAME"):
			ip_address =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	elif OS.has_feature("OSX"):
		if OS.has_environment("HOSTNAME"):
			ip_address =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),1)
	return ip_address
