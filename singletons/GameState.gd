extends Node

signal score_to_win_changed_by
signal ping_visible_changed

signal init_params_changed
signal score_changed

signal started_initialization
signal started_game
signal ended_game
signal returned_to_menu

enum STATE {
	MENU,
	INITIALIZING,
	STARTED,
	ENDED,
}

enum END_STATE {
	WON,
	LOST,
	DISCONNECTED,
	LEFT_WON,
	RIGHT_WON
}

const START_TIMER_WAIT = 3

var state = STATE.MENU

var Settings = {
	ping_visible = false
}

var InitParams = {
	score_to_win = 3,
} setget set_init_params

var Score = {
	master_score = 0,
	slave_score = 0
} setget set_score

var start_timer = Timer.new()

func _ready():
	add_child(start_timer)
	get_tree().connect('network_peer_connected', self, 'initiate_state')
	get_tree().connect('network_peer_connected', self, '_start_initial_countdown')
	Network.connect('started_locally', self, '_start_initial_countdown')

func initiate_state(id = 0):
	rset_config('Score', Node.RPC_MODE_REMOTE)
	rset_config('InitParams', Node.RPC_MODE_REMOTE)
	if Network.is_server():
		rset('InitParams', InitParams)

func set_score_to_win(new_score, edited_by):
	InitParams.score_to_win = new_score
	emit_signal('score_to_win_changed_by', new_score, edited_by)

func set_ping_visible(ping_visible):
	Settings.ping_visible = ping_visible
	emit_signal('ping_visible_changed', ping_visible)

func set_init_params(new_init_params):
	InitParams = new_init_params
	emit_signal('init_params_changed', InitParams)

func set_score(new_score):
	Score = new_score
	if Score.master_score >= InitParams.score_to_win \
		or Score.slave_score >= InitParams.score_to_win:
				end_game()
	if Network.is_server():
		rset('Score', Score)
	print('score was changed')
	emit_signal('score_changed', Score)

remote func start_initialization():
	if state == STATE.INITIALIZING:
		return
	if state == STATE.ENDED:
		rpc('start_initialization')
		initiate_state()
		_start_initial_countdown()
	print('started initialization')
	_reset_score()
	if !get_tree().get_root().has_node('Game'):
		var Game = load('res://game/Game.tscn').instance()
		get_tree().get_root().add_child(Game)
	state = STATE.INITIALIZING
	emit_signal('started_initialization')

func _reset_score():
	set_score({
		master_score = 0,
		slave_score = 0
	})

func start_game():
	if state == STATE.STARTED:
		return
	print('started game')	
	state = STATE.STARTED
	emit_signal('started_game')

func end_game():
	if state == STATE.ENDED\
		or state == STATE.MENU:
		return
	print('ended game')
	state = STATE.ENDED
	emit_signal('ended_game', _has_won())

func _has_won():
	if Network.is_local_only:
		if Score.master_score >= InitParams.score_to_win:
			return END_STATE.LEFT_WON
		elif Score.slave_score >= InitParams.score_to_win:
			return END_STATE.RIGHT_WON
	if !Network._has_active_connections():
		return END_STATE.DISCONNECTED
	if Network.is_server() and Score.master_score >= InitParams.score_to_win \
		or !Network.is_server() and Score.slave_score >= InitParams.score_to_win:
		return END_STATE.WON
	return END_STATE.LOST

func return_to_menu():
	if state == STATE.MENU:
		return
	state = STATE.MENU
	get_tree().get_root().get_node('Game').queue_free()
	get_tree().get_root().get_node('MainMenu').show()
	emit_signal('returned_to_menu')

sync func _start_initial_countdown(id = 0):
	start_timer.set_wait_time(START_TIMER_WAIT)
	start_timer.set_one_shot(true)
	start_timer.start()