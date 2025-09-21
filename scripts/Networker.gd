extends Control

signal player_connected(peer_id, player_info, is_server)
signal player_disconnected(peer_id, name)
signal server_disconnected()
signal order_generated(play_order)

const PORT = 8080

var share_addr

var players = {}
var own_info = {"name" : null, "skips": 0}
var peer
var players_loaded = 0

# game related variables.
var playing_order = []
var turn_idx = -1
var turn_offset = 1

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
	player_connected.emit(new_id, player_info, multiplayer.is_server())
	

func _on_player_disconnected(id):
	var player_name = players[id]["name"]
	players.erase(id)
	player_disconnected.emit(id, player_name)
	
func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = own_info

func _on_connected_fail():
	multiplayer.multiplayer_peer = null
	
func _on_server_disconnected():
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()

func update_player_info(name):
	own_info["name"] = name

func host_game() -> String:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, 4)
	if error:
		return error
		
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer
	
	players[1] = own_info
	
	share_addr = upnp_setup(PORT)
	
	return "OK"
	
func join_game(addr):
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(addr, PORT)
	if error:
		return error
	
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	
	multiplayer.multiplayer_peer = peer
	return "OK"

func upnp_setup(server_port):
	var upnp = UPNP.new()
	var err = upnp.discover()

	if err != OK:
		push_error(str(err))
		return

	if upnp.get_gateway() and upnp.get_gateway().is_valid_gateway():
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "UDP")
		upnp.add_port_mapping(server_port, server_port, ProjectSettings.get_setting("application/config/name"), "TCP")
	
	return upnp.query_external_address()
	
func request_start_game():
	if players.size() == 4:
		start_game()
		return ""
	else:
		return "not_enough_players"
	
func start_game():
	print(players)
	load_game.rpc()

@rpc("call_local", "reliable")
func load_game() -> void:
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")

@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game/GameManager.start_game()

func leave_game():
	multiplayer.multiplayer_peer.close()

func get_players():
	return players

func get_info():
	return own_info

func get_name_from_id(player_id):
	return players[player_id]["name"]

# game related functions.
func generate_order():
	for id in players:
		playing_order.append(id)
	playing_order.shuffle()
	order_generated.emit(playing_order)
	sendPlayingOrder.rpc(playing_order)

@rpc
func sendPlayingOrder(PO):
	order_generated.emit(PO)

func advance_turn():
	if players.is_empty():
		return
	turn_idx = (turn_idx + turn_offset + players.size()) % players.size()
	var curr_pid = playing_order[turn_idx]
	$/root/Game/GameManager.process_turn(curr_pid)

func reverse_turn():
	turn_offset *= -1
