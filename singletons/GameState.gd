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

func _ready():
	get_tree().connect('network_peer_connected', self, 'initiate_state')

func initiate_state(id):
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

func start_initialization():
	if state == STATE.INITIALIZING:
		return
	_reset_score()
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
	state = STATE.STARTED
	emit_signal('started_game')

func end_game():
	if state == STATE.ENDED:
		return
	state = STATE.ENDED
	emit_signal('ended_game')

func return_to_menu():
	if state == STATE.MENU:
		return
	state = STATE.MENU
	emit_signal('returned_to_menu')