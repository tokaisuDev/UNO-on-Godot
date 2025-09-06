extends Node2D

func pile_check() -> void:
	if get_child_count() > 10:
		for child in get_children():
			child.z_index -= 1
		var CardToBeDeleted = get_child(0)
		CardToBeDeleted.queue_free()
