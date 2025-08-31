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
		print("neh")
		return
	for i in range(1,4):
		var op_hand = get_node("OpHand%s" % str(i))
		if op_hand.owner_id == player_id:
			print(op_hand.owner_id)
			op_hand.spawn_card_with_slide("back", "cover")
			break

func assigningOpponentsToHands(playing_order):
	var player_idx
	for i in range(4):
		if playing_order[i] == multiplayer.get_unique_id():
			player_idx = i
			break
	for i in range(1,3):
		player_idx += 1
		player_idx = player_idx % 4
		var op_hand = get_node("OpHand%s" % str(i))
		op_hand.owner_id = 	playing_order[player_idx]

func _on_deck_pressed() -> void:
	$GameManager.request_draw_card.rpc_id(1)

func _on_game_manager_played_card(player_id: Variant, card: Variant) -> void:
	if player_id == multiplayer.get_unique_id():
		return
	else:
		for i in range(1,4):
			var op_hand = get_node("../OpHand%s" % str(i))
			if op_hand.owner_id == player_id:
				op_hand.play_card_as_opponent(card)
				break
