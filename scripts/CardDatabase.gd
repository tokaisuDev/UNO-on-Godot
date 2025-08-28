extends Node

const CARD_SHEET := preload("res://assets/uno_cards.png")

const NORM_COLORS := ["yellow", "red", "blue", "green"]
const VALUES := ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "+2", "skip", "reverse"]
const WILD_VALUES := ["+4", "wild"]

var card_textures := {}

func _ready():
	load_textures("back_cover")
	for i in NORM_COLORS.size():
		for j in VALUES.size():
			var color = NORM_COLORS[i]
			var value = VALUES[j]
			
			load_textures("%s_%s" % [color, value])
	for wild_val in WILD_VALUES:
		load_textures("black_%s" % wild_val)
	
func load_textures(tname: String):
	var dir = DirAccess.open("res://assets/cards")
	if dir.file_exists("%s.png" % [tname]):
		var tex = load("res://assets/cards/%s.png" % [tname])
		card_textures[tname] = tex
	else:
		push_warning("texture doesn't exist/can't load: %s" % [tname])

func get_card_texture(color: String, value: String) -> Texture2D:
	var key = "%s_%s" % [color, value]
	return card_textures.get(key, null)
