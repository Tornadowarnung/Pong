extends Node

enum GameState {
	INITIALIZING,
	STARTED,
	PAUSED,
}

var game_state = GameState.INITIALIZING
var time_to_start = 3

var master_score = 0
var slave_score = 0

const score_to_win = 3

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

sync func _end_game():
	var main_menu = load('res://interface/MainMenu.tscn').instance()
	get_tree().get_root().add_child(main_menu)
	get_tree().get_root().get_node('Game').queue_free()

func _on_player_disconnected(id):
	get_node(str(id)).queue_free()

func _on_server_disconnected():
	get_tree().change_scene('res://interface/MainMenu.tscn')

func _on_goal(master_scored):
	if master_scored:
		master_score += 1
		rset('master_score', master_score)
	else:
		slave_score += 1
		rset('slave_score', slave_score)
	if master_score >= score_to_win || slave_score >= score_to_win:
		rpc('_end_game')