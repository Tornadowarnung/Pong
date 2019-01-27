extends VBoxContainer

signal changed_menu

var AVAILABLE_MENUES = load('res://interface/available_menus.gd').AVAILABLE_MENUES

func _ready():
	hide()
	GameState.connect('ping_visible_changed', self, 'set_ping_pressed')
	GameState.connect('score_to_win_changed_by', self, 'set_score_to_win')

func _on_ScoreInput_text_changed(new_text):
	if int(new_text) > 0 and int(new_text) != GameState.InitParams.score_to_win:
		GameState.set_score_to_win(int(new_text), get_path())

func _on_Back_pressed():
	emit_signal('changed_menu', AVAILABLE_MENUES.Initial)

func _on_Host_pressed():
	Network.create_server()
	GameState.start_initialization()

func _on_PingInput_toggled(button_pressed):
	GameState.set_ping_visible(button_pressed)

func set_ping_pressed(button_pressed):
	$Pingcontainer/PingInput.pressed = button_pressed

func set_score_to_win(new_score, set_by):
	if get_path() == set_by:
		return
	$ScoreContainer/ScoreInput.text = str(new_score)