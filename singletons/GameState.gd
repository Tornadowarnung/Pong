extends Node

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

func initiate_state(id = 0):
	rset_config('Score', Node.RPC_MODE_REMOTE)
	rset_config('InitParams', Node.RPC_MODE_REMOTE)
	if Network.is_server():
		rset('InitParams', InitParams)

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
	Score.master_score = 0
	Score.slave_score = 0

func start_game():
	if state == STATE.STARTED:
		return
	print('started game')	
	state = STATE.STARTED
	emit_signal('started_game')

func end_game():
	if state == STATE.ENDED:
		return
	print('ended game')
	state = STATE.ENDED
	emit_signal('ended_game', _has_won())

func _has_won():
	if Network.is_server() and Score.master_score >= InitParams.score_to_win \
		or !Network.is_server() and Score.slave_score >= InitParams.score_to_win:
		return true
	return false

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