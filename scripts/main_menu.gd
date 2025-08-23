extends Control

var player_list
var connected = false

func _ready() -> void:
	Lobby.player_connected.connect(_on_player_connect)
	Lobby.player_disconnected.connect(_on_player_disconnect)
	Lobby.server_disconnected.connect(_on_server_disconnect)

func update_player_list():
	player_list = Lobby.get_players()

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
	Lobby.update_player_info($username_field.text)
	Lobby.join_game()
	
	$err_text.text = "[color=#5cb85c]Joined as %s[/color] [color=FFDE21]Waiting for other players...[/color]" % $username_field.text
	update_player_list()
	show_players()

func _on_host_button_button_down() -> void:
	if $username_field.text == "":
		$err_text.text = "[color=#ED4337]Please enter your in-game name before joining.[/color]"
		return
		
	Lobby.update_player_info($username_field.text)
	
	var status = Lobby.host_game()
	if status != "OK":
		$err_text.text = "[color=#ED4337]Failed to host game: %s[/color]" % str(status)
		return
	
	connected = true
	
	$join_button.visible = false
	$host_button.visible = false
	$start_game_btn.visible = true
	$err_text.text = "[color=#5cb85c]You are now the host of a game.[/color] [color=FFDE21]Waiting for other players...[/color]"
	update_player_list()
	show_players()

func _on_leave_button_button_down() -> void:
	Lobby.leave_game()
	connected = false
	
	$leave_button.visible = false
	$join_button.visible = true
	$host_button.visible = true
	

func _on_start_game_btn_button_down() -> void:
	pass # Replace with function body.

func _on_player_disconnect(pid, name):
	if not connected:
		return
	$err_text.text = "%s has disconnected." % name
	update_player_list()
	show_players()
	
func _on_player_connect(pid, info, is_server):
	if info != Lobby.get_info() and is_server:
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
