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
	ip = ip.replace("GFD","Y")
	ip = ip.replace("GMHD","X")
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

func findLocalIP() -> String:
	var ip = ""
	for address in IP.get_local_addresses():
		if "." in address and not address.begins_with("127.") and not address.begins_with("169.254."):
			if address.begins_with("192.168.") or address.begins_with("10.") or (address.begins_with("172.") and int(address.split(".")[1]) >= 16 and int(address.split(".")[1]) <= 31):
				print(address.split(".")[1])
				ip = address
				break
	return ip
