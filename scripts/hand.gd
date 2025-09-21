extends Node2D

signal card_discarded
signal play_impossible

var CardScene = preload("res://scenes/Card.tscn")
var back_cover = preload("res://assets/cards/back_cover.png")
var owned = false
var owner_id : int = -1
var play_approved = false

func _process(delta: float):
	if not owned:
		return
	var mouse_pos = get_global_mouse_position()
	var target_card = -1
	var z_max = -999
	
	for i in range(get_child_count()):
		var card = get_child(i)
		if card.get_rect().has_point(card.to_local(mouse_pos)):
			if card.z_index > z_max:
				z_max = card.z_index
				target_card = i
	
	for i in range(get_child_count()):
		var card = get_child(i)
		if i == target_card:
			card.hover_up()
		else:
			card.hover_down()
			
	if target_card != -1 and Input.is_action_just_pressed("click"):
		var card = get_child(target_card)
		play_card(card)

func spawn_card_with_slide(color, value):
	var card
	card = CardScene.instantiate()
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

	for i in range(get_child_count()):
		var card = get_child(i)
		var target_pos = Vector2(start_x + i * spacing, 0)
		card.z_index = i
		
		# tween for a smooth slide
		var tween = create_tween()
		tween.tween_property(card, "position", target_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		card.update_original_pos(target_pos)
		card.hover_down()

func on_play_approval(card_index):
	var picked_card = get_child(card_index)
	play_card_animation(picked_card)

func play_card(card):
	var card_index = card.z_index
	$"../GameManager".request_play_card.rpc_id(1, card.card_color, card.card_value, card_index)

func play_card_as_opponent(card_color, card_value, card_index):
	if owned:
		return
	var card_to_be_played = get_child(card_index)
	card_to_be_played.setup(card_color, card_value)
	play_card_animation(card_to_be_played)

func play_card_animation(card):
	$"../DiscardPile".pile_check()
	var card_global_pos = card.global_position
	card.reparent($"../DiscardPile")
	card.global_position = card_global_pos
	
	var target_pos = $"../DiscardPile".global_position
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(card, "global_position", target_pos, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(card, "rotation_degrees", randf_range(-80, 80), 0.5)
	card.z_index = $"../DiscardPile".get_child_count()
	
	layout_hand()
	if get_child_count() == 0:
		$"../GameManager".request_end_game()

func _on_game_manager_player_turn(player_id: Variant) -> void:
	if player_id == multiplayer.get_unique_id():
		for card in get_children():
			if $"../GameManager".playable_check(card.card_color, card.card_value):
				return
			$"../GameManager".execute_penalties()
