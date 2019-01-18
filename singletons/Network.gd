extends Node

const UPDATE_TIME = 0.01
const MASTER_POSITION = Vector2(30, 300)

var peer
var ip_address = '127.0.0.1' setget set_ip
var port = 12345
const MAX_PLAYERS = 2

signal ping_changed
signal ticked

var tick_timer = Timer.new()

var Ping = {	
	start_time = 0,
	ping = 0,
	timer = Timer.new()
}

var players = { }
var self_data = { name = '', position = MASTER_POSITION }

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	get_tree().connect('connected_to_server', self, '_connected_to_server')
	
	GameState.connect('returned_to_menu', self, 'disconnect')
	
	tick_timer.connect('timeout', self, '_on_tick_timer_timeout')
	tick_timer.set_wait_time(UPDATE_TIME)
	tick_timer.set_one_shot(false)
	add_child(tick_timer)
	tick_timer.start()
	
	Ping.timer.connect('timeout', self, '_send_ping_request')
	Ping.timer.set_wait_time(1)
	Ping.timer.set_one_shot(false)
	add_child(Ping.timer)
	Ping.timer.start()

func set_ip(ip):
	ip_address = ip

func create_server(player_nickname):
	self_data.name = player_nickname
	self_data.position = MASTER_POSITION
	players[1] = self_data
	peer = NetworkedMultiplayerENet.new()
	var error = peer.create_server(port, MAX_PLAYERS - 1)
	print("Creating server at port ", port, " with error code ", error)
	get_tree().set_network_peer(peer)

func connect_to_server(player_nickname):
	self_data.name = player_nickname
	self_data.position = Vector2(get_viewport().get_visible_rect().size.x - 30 , 300)
	peer = NetworkedMultiplayerENet.new()
	var error = peer.create_client(ip_address, port)
	print("Connecting to ", ip_address, ":", port, " with error code ", error)
	get_tree().set_network_peer(peer)

func _connected_to_server():
	players[get_tree().get_network_unique_id()] = self_data
	rpc('_send_player_info', get_tree().get_network_unique_id(), self_data)

func _on_player_disconnected(id):
	print('Player disconnected: ' + players[id].name)
	players.erase(id)

func _on_server_disconnected():
	print('Server disconnected')
	players.clear()
	peer.close_connection()

remote func _send_player_info(id, info):
	if get_tree().is_network_server():
		for peer_id in players:
			rpc_id(id, '_send_player_info', peer_id, players[peer_id])
	players[id] = info
	
	var new_player = load('res://phyiscalObjects/player/Player.tscn').instance()
	new_player.name = str(id)
	new_player.set_network_master(id)
	$'/root/Game/'.add_player(new_player)
	new_player.init(info.name, info.position, true)

func _send_ping_request():
	if !_has_active_connections():
		return
	Ping.start_time = OS.get_ticks_msec()
	rpc_unreliable('_receive_ping_request')
	

remote func _receive_ping_request():
	rpc_unreliable('_ping_response')

remote func _ping_response():
	Ping.ping = OS.get_ticks_msec() - Ping.start_time
	emit_signal('ping_changed', Ping.ping)

func are_all_players_connected():
	return bool(players.size() == MAX_PLAYERS)

func disconnect():
	players.clear()
	peer.close_connection()

func _on_tick_timer_timeout():
	emit_signal('ticked')

func is_server():
	return _has_active_connections() and get_tree().is_network_server()

func _has_active_connections():
	return get_tree().get_network_peer() != null and get_tree().get_network_peer().get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_CONNECTED