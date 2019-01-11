extends Node

const UPDATE_TIME = 0.025
const MASTER_POSITION = Vector2(30, 300)

var peer
var ip_address = '127.0.0.1'
var port = 12345
const MAX_PLAYERS = 2

var players = { }
var self_data = { name = '', position = MASTER_POSITION }

signal player_disconnected
signal server_disconnected

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')

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
	get_tree().connect('connected_to_server', self, '_connected_to_server')
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
	get_tree().get_root().get_node('MainMenu').show()
	get_tree().get_root().get_node('Game').queue_free()

remote func _send_player_info(id, info):
	if get_tree().is_network_server():
		for peer_id in players:
			rpc_id(id, '_send_player_info', peer_id, players[peer_id])
	players[id] = info
	
	var new_player = load('res://player/Player.tscn').instance()
	new_player.name = str(id)
	new_player.set_network_master(id)
	$'/root/Game/'.add_child(new_player)
	new_player.init(info.name, info.position, true)

func are_all_players_connected():
	return bool(players.size() == MAX_PLAYERS)

func disconnect():
	players.clear()
	peer.close_connection()