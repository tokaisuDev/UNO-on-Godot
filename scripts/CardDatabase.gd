extends Node

const CARD_WIDTH := 165
const CARD_HEIGHT := 256
const SHEET_SZ := 2009

const CARD_SHEET := preload("res://assets/uno_cards.png")

const COLORS := ["black", "yellow", "red", "blue", "green"]
const NORM_COLORS := ["yellow", "red", "blue", "green"]
const VALUES := ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "+2", "skip", "reverse", "wild", "+4"]

var card_textures := {}

func _ready():
	load_textures("back_cover")
	for i in COLORS.size():
		for j in VALUES.size():
			var color = COLORS[i]
			var value = VALUES[j]
			
			load_textures("%s_%s" % [color, value])

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
