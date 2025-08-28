extends Node2D

func _ready():
	$Hand.owned = true

func _on_button_button_down() -> void:
	$Hand.spawn_card_with_slide("blue", "5")
