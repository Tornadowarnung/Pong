extends Node

const START_TIMER_WAIT = 3

var all_players = []

var start_timer = Timer.new()

func _ready():
	GameState.connect('score_changed', self, '_update_score_labels')
	GameState.connect('init_params_changed', self, '_on_init_params_changed')
	GameState.connect('started_game', self, '_start_game')
	GameState.connect('ended_game', self, '_end_game')
	
	start_timer.connect('timeout', GameState, 'start_game')	
	
	Network.connect('ping_changed', self, '_on_ping_change')
	get_tree().connect('network_peer_connected', self, '_start_initial_countdown')
	
	var new_player = preload('res://player/Player.tscn').instance()
	new_player.name = str(get_tree().get_network_unique_id())
	new_player.set_network_master(get_tree().get_network_unique_id())
	add_player(new_player)
	var info = Network.self_data
	new_player.init(info.name, info.position, false)
	
	if GameState.Settings.ping_visible:
		$Interface/Ping.show()
	else:
		$Interface/Ping.hide()
	
	$Interface/GameStartContainer/GameStartContainer/ScoreToWin.text += str(GameState.InitParams.score_to_win)

func _start_initial_countdown(id):
	start_timer.set_wait_time(START_TIMER_WAIT)
	start_timer.set_one_shot(true)
	add_child(start_timer)
	start_timer.start()

func _process(delta):
	if !start_timer.is_stopped():
		$Interface/GameStartContainer/GameStartContainer/TimeToStart.text = str(int(start_timer.get_time_left()) + 1)

func _start_game():
	$Interface/GameStartContainer.hide()
	$Puck.start()
	for player in all_players:
		player.start()

sync func _end_game():
	Network.disconnect()
	get_tree().get_root().get_node('MainMenu').show()
	get_tree().get_root().get_node('Game').queue_free()

func _on_goal(master_scored):
	if master_scored:
		GameState.Score.master_score += 1
	else:
		GameState.Score.slave_score += 1

func _update_score_labels(score):
	$Interface/ScoreContainer/CenterContainer/MasterScoreLabel.text = str(score.master_score)
	$Interface/ScoreContainer/CenterContainer2/ClientScoreLabel.text = str(score.slave_score)

func _on_init_params_changed(params):
	$Interface/GameStartContainer/GameStartContainer/ScoreToWin.text = "Score to win: " + str(params.score_to_win)

func _on_ping_change(ping):
	$Interface/Ping.text = str(ping)

func add_player(player):
	all_players.append(player)
	add_child(player)