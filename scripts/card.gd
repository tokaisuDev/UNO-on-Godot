extends Area2D

@export var card_color: String
@export var card_value: String
var owned = true

var tween: Tween
var original_position: Vector2
var setup_finished = false

func _ready():
	original_position = position

func setup(color: String, value: String):
	setup_finished = true
	card_color = color
	card_value = value
	
	update_card_texture()
	
func update_card_texture():
	var tex = CardDatabase.get_card_texture(card_color, card_value)
	if tex:
		$Sprite2D.texture = tex
	else:
		push_warning("Card texture not found: %s %s" % [card_color, card_value])

func update_original_pos(pos):
	original_position = pos

func hover_up():
	if position.y == original_position.y-20:
		return
	var tween = create_tween()
	tween.tween_property(self, "position:y", original_position.y-20, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func hover_down():
	if position.y == original_position.y:
		return
	var tween = create_tween()
	tween.tween_property(self, "position:y", original_position.y, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func get_rect() -> Rect2:
	if $Sprite2D.texture:
		var tex_size = $Sprite2D.texture.get_size()
		return Rect2(-tex_size.x / 2, -tex_size.y / 2, tex_size.x, tex_size.y)
	return Rect2()
