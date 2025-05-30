extends CanvasLayer
class_name hostSetup

@onready var host_text = $HostText
@onready var store_player_names = $storePlayerNames
@onready var join_code = $JoinCode
const NAME = preload("res://Classes/Networking/Host/name.tscn")

func _ready():
	var ip = findLocalIP()
	for i in range(ip.length()):
		var uni = ip.unicode_at(i)
		ip[i] = String.chr(uni + 22)
	ip = ip.replace("GOHDGLND","Z")
	join_code.text = "Code: " + ip

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
			ip_address =  IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")),IP.Type.TYPE_IPV4)
	elif OS.has_feature("x11"):
		if OS.has_environment("HOSTNAME"):
			ip_address =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),IP.Type.TYPE_IPV4)
	elif OS.has_feature("OSX"):
		if OS.has_environment("HOSTNAME"):
			ip_address =  IP.resolve_hostname(str(OS.get_environment("HOSTNAME")),IP.Type.TYPE_IPV4)
	return ip_address
