extends Node2D

func _ready():
	$Hand.owned = true

func _on_button_button_down() -> void:
	$Hand.spawn_card_with_slide("blue", "5")
	$Hand2.spawn_card_with_slide("back", "cover")
	$Hand3.spawn_card_with_slide("back", "cover")
	$Hand4.spawn_card_with_slide("back", "cover")
	
