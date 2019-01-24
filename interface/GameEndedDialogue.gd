extends Panel

export var won_foreground_color = Color('#1f8001')
export var won_background_color = Color('#00ffe1')
export var lost_error_foreground_color = Color('#a50000')
export var lost_error_background_color = Color('#c98d00')

const DISCONNECT_WARNING = "The other player disconnected"
const REMATCH_RECEIVED = "The other player challenges you to a rematch"
const REMATCH_REQUESTED = "A rematch request was sent to the other player"

onready var Title = $VBoxContainer/Title
onready var Warning = $VBoxContainer/Warning
onready var ReplayButton = $VBoxContainer/Buttons/ReplayButton

var is_disconnected = false
var rematch_was_requested = false

func _ready():
	hide()
	GameState.connect('started_initialization', self, '_on_initialization_started')
	GameState.connect('ended_game', self, '_end_game')
	get_tree().connect('network_peer_disconnected', self, '_on_disconnect')
	get_tree().connect('server_disconnected', self, '_on_disconnect')

func _on_initialization_started():
	hide()
	Warning.hide()
	ReplayButton.set_disabled(false)
	is_disconnected = false
	rematch_was_requested = false

func _end_game(end_state):
	if end_state == GameState.END_STATE.WON:
		Title.text = "You've won"
		set_title_colors_to(won_foreground_color, won_background_color)
	elif end_state == GameState.END_STATE.LOST:
		Title.text = "You've lost"
		set_title_colors_to(lost_error_foreground_color, lost_error_background_color)
	elif end_state == GameState.END_STATE.DISCONNECTED:
		Title.text = "Connection Error"
		set_title_colors_to(lost_error_foreground_color, lost_error_background_color)
	else:
		Title.text = "Unknown Error"
		set_title_colors_to(lost_error_foreground_color, lost_error_background_color)
	show()

func set_title_colors_to(foreground, background):
	Title.add_color_override('font_color', foreground)
	Title.add_color_override('font_color_shadow', background)

func _on_disconnect(id = 0):
	is_disconnected = true
	Warning.text = DISCONNECT_WARNING
	Warning.show()
	ReplayButton.set_disabled(true)

func _on_BackButton_pressed():
	GameState.return_to_menu()

func _on_ReplayButton_pressed():
	if rematch_was_requested:
		rpc("start_rematch")
		return
	rpc("request_rematch")
	Warning.text = REMATCH_REQUESTED
	ReplayButton.set_disabled(true)
	Warning.show()

remote func request_rematch():
	rematch_was_requested = true
	Warning.text = REMATCH_RECEIVED
	Warning.show()

sync func start_rematch():
	GameState.start_initialization()