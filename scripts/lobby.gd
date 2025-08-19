extends Control

signal player_connected()
signal player_disconnected()
signal server_disconnected()

const PORT = 8080
const ADDR = "192.168.1.99"

var players = {}

var peer

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_player_connected(id):
	register_player.rpc_id(id, own_info)

@rpc("any_peer", "reliable")
func register_player(player_info):
	var new_id = multiplayer.get_remote_sender_id()
	players[new_id] = player_info
	player_connected.emit(new_id, player_info)
	

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit()
	
func _on_connected_ok():
	print("im connected")
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = own_info
	player_connected.emit()

func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	#$err_text.bbcode_text = "[color=#ED4337]You have been disconnected from the server.[/color]"

func host_game() -> void:
	#if $username_field.text == "":
		#$err_text.bbcode_text = "[color=#ED4337]Please enter your in-game name before hosting.[/color]"
		#return
	own_info["name"] = $username_field.text
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 4)
	if error != OK:
		$err_text.text = "[color=#ED4337]Can't host: %s[/color]" % str(error)
		return
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer
	
	players[1] = own_info
	print(players)
	player_connected.emit()
	$err_text.text = "[color=#5cb85c]You are now the host of a game.[/color] [color=FFDE21]Waiting for other players...[/color]"

func join_game() -> void:
	own_info["name"] = $username_field.text
	peer = ENetMultiplayerPeer.new()
	peer.create_client(ADDR, PORT)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer

func start_game() -> void:
	
	pass # Replace with function body.
