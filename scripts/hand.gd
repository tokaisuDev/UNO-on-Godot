extends Node2D

var CardScene = preload("res://scenes/Card.tscn")
var owned = false

func _process(delta: float):
	var mouse_pos = get_global_mouse_position()
	var card_to_be_raised_idx = -1
	var z_max = -999
	
	for i in get_child_count():
		var card = get_child(i)
		if card.get_rect().has_point(card.to_local(mouse_pos)):
			if card.z_index > z_max:
				z_max = card.z_index
				card_to_be_raised_idx = i
				
	for i in get_child_count():
		var card = get_child(i)
		if i == card_to_be_raised_idx:
			card.hover_up()
		else:
			card.hover_down()

func spawn_card_with_slide(color, value):
	var card = CardScene.instantiate()
	card.setup(color, value)

	var final_index = get_child_count()
	var spacing = 60
	var final_pos = Vector2(-((final_index) * spacing) / 2 + final_index * spacing, 0)

	card.position = Vector2(1000, 0)  # Offscreen start
	add_child(card)
	card.z_index = final_index

	# Use built-in tweening (no need for a Tween node)
	var tween = create_tween()
	tween.tween_property(card, "position", final_pos, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	await tween.finished
	layout_hand()

func layout_hand():
	var spacing = 60
	var start_x = -((get_child_count() - 1) * spacing) / 2

	for i in get_child_count():
		var card = get_child(i)
		var target_pos = Vector2(start_x + i * spacing, 0)
		card.z_index = i
		
		# tween for a smooth slide
		var tween = create_tween()
		tween.tween_property(card, "position", target_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		card.update_original_pos(card.position)
