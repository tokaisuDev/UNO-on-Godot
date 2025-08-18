extends Control

signal player_connected()
signal player_disconnected()
signal server_disconnected

const PORT = 4040
const ADDR = "192.168.1.99"

var players = {}
var own_info = {"name": null}
var peer

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

@rpc("any_peer", "reliable")
func register_player(player_info):
	var new_id = multiplayer.get_remote_sender_id()
	players[new_id] = player_info
	player_connected.emit(new_id, player_info)
	
func _on_player_connected(id):
	register_player.rpc_id(id, own_info)

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit()
	
func _on_connected_ok(id):
	prints("Connected to server!", id)

func _on_connected_fail(id):
	prints("Failed to connect player", id)
	
func _on_server_disconnected(id):
	prints("Disconnected from server!", id)

func _on_host_button_button_down() -> void:
	if $username_field.text == "":
		$err_text.bbcode_text = "[color=#ED4337]Please enter your in-game name before hosting.[/color]"
		return
	own_info["name"] = $username_field.text
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 4)
	if error != OK:
		$err_text.text = "[color=#ED4337]Can't host: %s[/color]" % str(error)
		return
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	$err_text.text = "[color=#5cb85c]Joined server successfully![/color] [color=FFDE21]Waiting for other players...[/color]"

func _on_join_button_button_down() -> void:
	if $username_field.text == "":
		$err_text.text = "[color=#ED4337]Please enter your in-game name before joining.[/color]"
		return
		
	own_info["name"] = $username_field.text
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ADDR, PORT)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.set_multiplayer_peer(peer)
	$err_text.text = "[color=#5cb85c]Joined server successfully![/color]"

func _on_start_game_btn_button_down() -> void:
	
	pass # Replace with function body.
