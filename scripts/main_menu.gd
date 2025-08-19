extends Control


func _on_join_button_button_down() -> void:
	if $username_field.text == "":
		$err_text.text = "[color=#ED4337]Please enter your in-game name before joining.[/color]"
		return
	
	$start_game_btn.visible = false
	
	Lobby.join_game()
	
	$err_text.text = "[color=#5cb85c]Joined server successfully![/color] [color=FFDE21]Waiting for other players...[/color]"

func _on_host_button_button_down() -> void:
	if $username_field.text == "":
		$err_text.text = "[color=#ED4337]Please enter your in-game name before joining.[/color]"
		return
	
	

func _on_start_game_btn_button_down() -> void:
	pass # Replace with function body.
