extends Area2D

@export var card_color: String
@export var card_value: String

var original_position: Vector2
var done = false

func _ready():
	original_position = position
	if done:
		update_card_texture()

	# Connect signals if not done in the editor
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))

func _input(event: InputEvent) -> void:
	if event == InputEventMouseButton:
		var mouse_over = get_global_mouse_position().distance_to(global_position) < 150
		if mouse_over:
			hover_up()
		else:
			hover_down()
			
func hover_up():
	if position.y == original_position.y-20:
		return
	var tween = create_tween()
	tween.tween_property(self, "position", original_position + Vector2(0, -20), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func hover_down():
	if position.y == original_position.y:
		return
	var tween = create_tween()
	tween.tween_property(self, "position", original_position, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func setup(color: String, value: String):
	done = true
	card_color = color
	card_value = value
	
	update_card_texture()
	
func update_card_texture():
	var tex = CardDatabase.get_card_texture(card_color, card_value)
	if tex:
		$Sprite2D.texture = tex
	else:
		push_warning("Card texture not found: %s %s" % [card_color, card_value])

func _on_mouse_entered():
	if position.y == original_position.y-20:
		return
	var tween = create_tween()
	tween.tween_property(self, "position", original_position + Vector2(0, -20), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_mouse_exited():
	position = original_position
