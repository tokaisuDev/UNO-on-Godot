extends Control

func _on_player_hand_card_discarded() -> void:
	if get_child_count() > 10:
		var CardToBeDeleted = get_child(0)
		CardToBeDeleted.queue_free()
