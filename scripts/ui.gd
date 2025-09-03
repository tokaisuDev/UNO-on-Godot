extends CanvasLayer

func _ready() -> void:
	Networker.order_generated.connect(assigning_names)
	
func assigning_names(playing_order):
	var players_info = Networker.get_players()
	var player_idx
	for i in range(4):
		if playing_order[i] == multiplayer.get_unique_id():
			player_idx = i
			break
	for i in range(1,4):
		player_idx += 1
		player_idx %= 4
		var usr_field = get_node("OpponentInfo%s" % str(i))
		usr_field.text = players_info[playing_order[player_idx]]["name"]

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
