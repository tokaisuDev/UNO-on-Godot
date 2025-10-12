extends CanvasLayer

func assigning_player_field(player_id, idx = -1):
	var player_name = Networker.players[player_id]["name"]
	if idx == -1:
		$PlayerInfo.text = player_name
	else:
		var player_label = get_node("OpponentInfo%s" % str(idx))
		player_label.text = player_name

func on_player_turn(player_id):
	var color = Color(249,168,0,1)
	if player_id == multiplayer.get_unique_id():
		$PlayerInfo.set("theme_override_colors/font_color", color)
	else:
		var name = Networker.get_name_from_id(player_id)
		for i in range(1,4):
			var op_label = get_node("OpponentInfo%s" % str(i))
			if op_label.text == name:
				op_label.set("theme_override_colors/font_color", color)
		
func on_turn_end(player_id):
	var color = Color(255,255,255,1)
	if player_id == multiplayer.get_unique_id():
		$PlayerInfo.set("theme_override_colors/font_color", color)
	else:
		var name = Networker.get_name_from_id(player_id)
		for i in range(1,4):
			var op_label = get_node("OpponentInfo%s" % str(i))
			if op_label.text == name:
				op_label.set("theme_override_colors/font_color", color)
