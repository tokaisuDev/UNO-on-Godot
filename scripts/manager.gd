extends Node

signal drew_card(player_id)
signal player_turn(player_id)
signal turn_end(player_id)
signal played_card(player_id, card_color, card_value)
signal play_approved

# nodes
var timer : Timer

# game variables
const on_start_card_amount = 7
const turn_time = 10
var deck = []
var early_game = true
var current_turn = null
var MostRecentCard = null
var players_info = {}

#effects
var cards_penalty = 0
var skips = 0

func _ready() -> void:
	#timer setup
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(_on_turn_timeout)

func renew_deck():
	for color in CardDatabase.NORM_COLORS:
		for value in CardDatabase.VALUES:
			deck.append([color, value])
	for wild_val in CardDatabase.WILD_VALUES:
		deck.append(["black", wild_val])
	deck.shuffle()

func get_card():
	if deck.is_empty():
		renew_deck()
	return deck.pop_back()
	
func give_card(player_id):
	var card = get_card()
	if player_id == 1:
		$"../PlayerHand".spawn_card_with_slide(card[0], card[1])
	else:
		drew_card.emit(player_id)
		receive_card.rpc_id(player_id, card)
	notify_card_draw.rpc(player_id)
	if not early_game:
		Networker.advance_turn()

@rpc
func receive_card(card):
	$"../PlayerHand".spawn_card_with_slide(card[0], card[1])

@rpc("any_peer", "call_local")
func request_draw_card():
	var caller_id = multiplayer.get_remote_sender_id()
	if caller_id != current_turn:
		return
	give_card(caller_id)
	Networker.advance_turn()

func playable_check(card_color, card_value):
	if MostRecentCard == null:
		return true
	if cards_penalty > 0 and card_value not in ["+2", "+4"]:
		return false
	if skips > 0 and card_value != "skip":
		return false
	if card_color != MostRecentCard[0] and card_value != MostRecentCard[1]:
		return false
	return true

@rpc("any_peer", "call_local")
func request_play_card(card_color, card_value):
	var approved = false
	if multiplayer.get_remote_sender_id() == current_turn:
		if playable_check(card_color, card_value):
			MostRecentCard = [card_color, card_value]
			if not timer.is_stopped():
				timer.stop()
			if card_value == "skip":
				skips += 1
			elif card_value == "+2":
				cards_penalty += 2
			elif card_value == "+4":
				cards_penalty += 4
			receive_play_permission.rpc_id(multiplayer.get_remote_sender_id(), true)
			played_card.emit(multiplayer.get_remote_sender_id(), card_color, card_value)
			notify_card_play.rpc(multiplayer.get_remote_sender_id(), card_color, card_value)
			Networker.advance_turn()
			approved = true
	if not approved:
		receive_play_permission.rpc_id(multiplayer.get_remote_sender_id(), false)

@rpc("authority", "call_local")
func receive_play_permission(is_play_approved):
	if is_play_approved:
		play_approved.emit()

@rpc
func notify_card_play(player_id, card_color, card_value):
	played_card.emit(player_id, card_color, card_value)

@rpc
func notify_card_draw(player_id):
	drew_card.emit(player_id)

@rpc
func notify_turn(player_id):
	player_turn.emit(player_id)
	
@rpc
func notify_turn_end(player_id):
	turn_end.emit(player_id)

func process_turn(player_id):
	if early_game:
		give_card(player_id)
	else:
		if players_info[player_id]["skips"] > 0:
			Networker.advance_turn()
			return
		if current_turn:
			turn_end.emit(current_turn)
			notify_turn_end.rpc(current_turn)
		current_turn = player_id
		timer.start(turn_time)
		player_turn.emit(player_id)
		notify_turn.rpc(player_id)

func _on_turn_timeout():
	if multiplayer.is_server():
		print("timeout")
		if cards_penalty > 0:
			while cards_penalty:
				give_card(current_turn)
				cards_penalty -= 1
			Networker.advance_turn()
		elif skips > 0:
			players_info[current_turn]["skips"] = skips
			skips = 0
			Networker.advance_turn()
		else:
			give_card(current_turn)

@rpc("any_peer", "call_local", "reliable")
func request_end_game():
	get_tree().change_scene_to_file("res://scenes/endgame_menu.tscn")

func start_game():
	if not multiplayer.is_server():
		return
	# game setup (early game)
	Networker.generate_order()
	players_info = Networker.get_players()
	for player in players_info:
		players_info[player]["skips"] = 0
	renew_deck()
	for k in range(on_start_card_amount):
		for i in range(4):
			Networker.advance_turn()
	early_game = false
	Networker.advance_turn()
