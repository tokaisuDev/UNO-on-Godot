extends Node2D

@onready var player_hand = get_node("PlayerHand")

func _ready():
	#signals
	$GameManager.drew_card.connect(opponent_draw_card)
	$GameManager.played_card.connect(_on_game_manager_played_card)
	Networker.order_generated.connect(assigningOpponentsToHands)
	# disabling visual effcts for opponents' hands
	player_hand.owned = true
	#networking
	Networker.player_loaded.rpc_id(1)

func opponent_draw_card(player_id):
	if player_id == multiplayer.get_unique_id():
		return
	for i in range(1,4):
		var op_hand = get_node("OpHand%s" % i)
		if op_hand.owner_id == player_id:
			op_hand.spawn_card_with_slide("back", "cover")
			break

func assigningOpponentsToHands(playing_order):
	var player_idx
	var positions = [0,1,2,3]
	if (playing_order.size() == 2):
		positions.erase(1)
		positions.erase(3)
	if (playing_order.size() == 3):
		positions.erase(2)
	for i in range(playing_order.size()):
		if playing_order[i] == multiplayer.get_unique_id():
			player_idx = i
			break
	$UI.assigning_player_field(playing_order[player_idx])
	for i in range(1,playing_order.size()):
		var op_hand = get_node("OpHand%s" % str(positions[i]))
		op_hand.owner_id = 	playing_order[(player_idx+i)%playing_order.size()]
		$UI.assigning_player_field(op_hand.owner_id, positions[i])

func _on_deck_pressed() -> void:
	print("p")
	$GameManager.request_draw_card.rpc_id(1)

func _on_game_manager_played_card(player_id: Variant, card_color: Variant, card_value, card_index) -> void:
	if player_id == multiplayer.get_unique_id():
		return
	else:
		prints("play from player", player_id)
		for i in range(1,4):
			var op_hand = get_node("OpHand%s" % str(i))
			if op_hand.owner_id == player_id:
				op_hand.play_card_as_opponent(card_color, card_value, card_index)
				break
