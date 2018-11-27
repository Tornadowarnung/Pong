extends Node

enum GameState {
	INITIALIZING,
	STARTED,
	PAUSED,
}

var game_state = GameState.INITIALIZING
var time_to_start = 3

func _ready():
	get_tree().connect('network_peer_disconnected', self, '_on_player_disconnected')
	get_tree().connect('server_disconnected', self, '_on_server_disconnected')
	
	var new_player = preload('res://player/Player.tscn').instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	add_child(new_player)
	var info = Network.self_data
	new_player.init(info.name, info.position, false)

func _process(delta):
	_countdown_to_start(delta)
	_start_game()

func _countdown_to_start(delta):
	if GameState.INITIALIZING != game_state || !Network.are_all_players_connected():
		return
	if time_to_start > 0:
		$Interface/TimeToStart.text = str(int(time_to_start) + 1)
		time_to_start -= delta
	else: 
		game_state = GameState.STARTED
		$Interface/TimeToStart.hide()

func _start_game():
	if GameState.STARTED != game_state:
		return
	$Puck.start()

func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene('res://interface/MainMenu.tscn')