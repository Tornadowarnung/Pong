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

var score_to_win_was_already_updated = false

func _ready():
	rset_config('master_score', Node.RPC_MODE_SYNC)
	rset_config('slave_score', Node.RPC_MODE_SYNC)
	
	var new_player = preload('res://player/Player.tscn').instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	add_player(new_player)
	var info = Network.self_data
	new_player.init(info.name, info.position, false)
	
	if GameStorage.ping_visible:
		$Interface/Ping.show()
	else:
		$Interface/Ping.hide()
	
	$Interface/GameStartContainer/GameStartContainer/ScoreToWin.text += str(GameStorage.score_to_win)

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
	if is_network_master():
		rpc('_update_score_to_win_label', GameStorage.score_to_win)
	if time_to_start > 0:
		$Interface/GameStartContainer/GameStartContainer/TimeToStart.text = str(int(time_to_start) + 1)
		time_to_start -= delta
	else: 
		game_state = GameState.STARTED
		$Interface/GameStartContainer.hide()

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
	rpc('_update_score_labels')
	if master_score >= GameStorage.score_to_win || slave_score >= GameStorage.score_to_win:
		rpc('_end_game')

sync func _update_score_labels():
	$Interface/ScoreContainer/CenterContainer/MasterScoreLabel.text = str(master_score)
	$Interface/ScoreContainer/CenterContainer2/ClientScoreLabel.text = str(slave_score)

remote func _update_score_to_win_label(winning_score):
	if score_to_win_was_already_updated:
		return
	$Interface/GameStartContainer/GameStartContainer/ScoreToWin.text = "Score to win: " + str(winning_score)
	score_to_win_was_already_updated = true

func add_player(player):
	all_players.append(player)
	add_child(player)