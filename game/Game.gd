extends Node

var all_players = []

func _ready():
	GameState.connect('score_changed', self, '_update_score_labels')
	GameState.connect('init_params_changed', self, '_on_init_params_changed')
	GameState.connect('started_initialization', self, '_on_initialization_started')
	GameState.connect('started_game', self, '_start_game')
	GameState.connect('ended_game', self, '_end_game')
	
	GameState.start_timer.connect('timeout', GameState, 'start_game')	
	
	Network.connect('ping_changed', self, '_on_ping_change')
	get_tree().connect('network_peer_disconnected', self, '_hide_replay_button')
	get_tree().connect('server_disconnected', self, '_hide_replay_button')
	
	$Puck.connect('scored_goal', self, '_on_goal')
	
	var new_player = preload('res://phyiscalObjects/player/Player.tscn').instance()
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
	$Interface/GameEndedDialogue.hide()

func _process(delta):
	if !GameState.start_timer.is_stopped():
		$Interface/GameStartContainer/GameStartContainer/TimeToStart.text = str(int(GameState.start_timer.get_time_left()) + 1)

func _on_initialization_started():
	$Interface/GameEndedDialogue.hide()
	$Interface/GameStartContainer.show()
	$Puck.set_position(Vector2(640, 300))
	for player in all_players:
		player.reset()

func _start_game():
	$Interface/GameStartContainer.hide()
	$Puck.start()
	for player in all_players:
		player.start()

sync func _end_game(has_won):
	$Puck.stop()
	for player in all_players:
		player.stop()
	if !has_won:
		$Interface/GameEndedDialogue/VBoxContainer/Title.text = "You've lost"
		$Interface/GameEndedDialogue/VBoxContainer/Title.add_color_override('font_color', Color('#a50000'))
		$Interface/GameEndedDialogue/VBoxContainer/Title.add_color_override('font_color_shadow', Color('#c98d00'))
	else:
		$Interface/GameEndedDialogue/VBoxContainer/Title.text = "You've won"
		$Interface/GameEndedDialogue/VBoxContainer/Title.add_color_override('font_color', Color('#1f8001'))
		$Interface/GameEndedDialogue/VBoxContainer/Title.add_color_override('font_color_shadow', Color('#00ffe1'))
	$Interface/GameEndedDialogue.show()

func _hide_replay_button(id = 0):
	$Interface/GameEndedDialogue/VBoxContainer/Warning.show()
	$Interface/GameEndedDialogue/VBoxContainer/Buttons/ReplayButton.set_disabled(true)

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

func _on_BackButton_pressed():
	GameState.return_to_menu()

func _on_ReplayButton_pressed():
	GameState.start_initialization()