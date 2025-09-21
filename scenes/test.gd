extends Node2D

func _ready():
	$Hand.owned = true
	$Card.setup("blue", "4")

func _on_button_button_down() -> void:
	$Hand.spawn_card_with_slide("blue", "5")
	


func _on_button_2_pressed() -> void:
	print("pressed")
