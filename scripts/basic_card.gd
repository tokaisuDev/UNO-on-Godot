extends Node2D

@export var color : String
@export var val : String



func _ready() -> void:
	color = "yellow"
	val = "1"
	update_card_texture()

func get_random_color():
	return ["red", "blue", "green", "yellow"].pick_random()

func get_random_value():
	return ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "skip", "reverse", "+2"].pick_random()
	
func update_card_texture():
	var tex = CardDatabase.get_card_texture(color, val)
	if tex:
		$Sprite2D.texture = tex
	else:
		push_warning("Card texture not found: %s %s" % [color, val])

func _on_button_pressed():
	color = get_random_color()
	val = get_random_value()
	prints(color, val)
	update_card_texture()
	visible = true
