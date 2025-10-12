extends Control

var player_list
var connected = false

func _ready() -> void:
	Networker.player_connected.connect(_on_player_connect)
	Networker.player_disconnected.connect(_on_player_disconnect)
	Networker.server_disconnected.connect(_on_server_disconnect)

func update_player_list():
	player_list = Networker.get_players()

func show_players():
	var final_text = ""
	for player in player_list:
		final_text += player_list[player]["name"] + '\n'
	$Label.text = final_text

func _on_join_button_button_down() -> void:
	if $username_field.text == "":
		$err_text.text = "[color=#ED4337]Please enter your in-game name before joining.[/color]"
		return
	
	$join_button.visible = false
	$start_game_btn.visible = false
	$host_button.visible = false
	$leave_button.visible = true
	
	connected = true
	Networker.update_player_info($username_field.text)
	Networker.join_game($address_field.text)
	
	$err_text.text = "[color=#5cb85c]Joined as %s[/color] [color=FFDE21]Waiting for other players...[/color]" % $username_field.text
	update_player_list()
	show_players()

func _on_host_button_button_down() -> void:
	if $username_field.text == "":
		$err_text.text = "[color=#ED4337]Please enter your in-game name before joining.[/color]"
		return
		
	Networker.update_player_info($username_field.text)
	
	var status = Networker.host_game()
	if status != "OK":
		$err_text.text = "[color=#ED4337]Failed to host game: %s[/color]" % str(status)
		return
	
	connected = true
	
	$join_button.visible = false
	$host_button.visible = false
	$start_game_btn.visible = true
	$err_text.text = "[color=#5cb85c]You are now the host of a game.[/color] [color=FFDE21]Here's your ip address: %s[/color]" % Networker.share_addr
	update_player_list()
	show_players()

func _on_leave_button_button_down() -> void:
	Networker.leave_game()
	connected = false
	
	$leave_button.visible = false
	$join_button.visible = true
	$host_button.visible = true
	

func _on_start_game_btn_button_down() -> void:
	var code = Networker.request_start_game()
	if code:
		$err_text.text = "[color=ED4337] You can't play alone."

func _on_player_disconnect(pid, name):
	if not connected:
		return
	$err_text.text = "%s has disconnected." % name
	update_player_list()
	show_players()
	
func _on_player_connect(pid, info, is_server):
	if info != Networker.get_info() and is_server:
		$err_text.text = "%s has joined the game." % info["name"]
	update_player_list()
	show_players()

func _on_server_disconnect():
	print("left")
	$err_text.text = "You have been disconnected from the server."
	player_list.clear()
	connected = false
	
	$leave_button.visible = false
	$join_button.visible = true
	$host_button.visible = true
	show_players()
