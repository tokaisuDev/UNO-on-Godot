extends Label

func load_text():
	var final_text = ""
	for player in Lobby.players:
		final_text += Lobby.players[player]["name"] + '\n'
	self.text = final_text
	self.visible = true
	
func _on_main_menu_player_connected() -> void:
	load_text()

func _on_main_menu_player_disconnected() -> void:
	load_text()
