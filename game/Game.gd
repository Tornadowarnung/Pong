extends Node

enum GameState {
	INITIALIZING,
	STARTED,
	PAUSED,
}

var all_players = []

var game_state = GameState.INITIALIZING
var time_to_start = 3

var master_score = 0
var slave_score = 0

var time_until_ping = 1

var score_to_win
var ping_visible

func _ready():
	var new_player = preload('res://player/Player.tscn').instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	add_player(new_player)
	var info = Network.self_data
	new_player.init(info.name, info.position, false)
	
	if ping_visible:
		$Interface/Ping.show()
	else:
		$Interface/Ping.hide()

func _process(delta):
	_countdown_to_start(delta)
	_start_game()
	
	time_until_ping -= delta
	if time_until_ping <= 0:
		time_until_ping = 1
		Network._send_ping_request()
		$Interface/Ping.text = str(Network.current_ping)

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
	for player in all_players:
		player.start()

sync func _end_game():
	if !is_network_master():
		Network.disconnect()
	else:
		Network.disconnect()
	get_tree().get_root().get_node('MainMenu').show()
	get_tree().get_root().get_node('Game').queue_free()

func _on_goal(master_scored):
	if master_scored:
		master_score += 1
		rset('master_score', master_score)
	else:
		slave_score += 1
		rset('slave_score', slave_score)
	print("slave: ", slave_score, ", master: ", master_score)
	if master_score >= score_to_win || slave_score >= score_to_win:
		rpc('_end_game')

func add_player(player):
	all_players.append(player)
	add_child(player)