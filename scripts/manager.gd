extends Node

@onready var player_hand = get_node("../PlayerHand")

func _ready():
	# Start the game with 7 cards
	for i in 7:
		player_hand.spawn_card_with_slide(get_random_color(), get_random_value())
		await get_tree().create_timer(2).timeout

func get_random_color():
	return ["red", "blue", "green", "yellow"].pick_random()

func get_random_value():
	return ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "skip", "reverse", "+2"].pick_random()
