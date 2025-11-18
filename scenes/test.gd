extends Node2D

func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property($cad, "global_position", $target_pos.global_position, 0.5)
