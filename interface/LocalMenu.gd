extends VBoxContainer

signal changed_menu

var AVAILABLE_MENUES = load('res://interface/available_menus.gd').AVAILABLE_MENUES

func _ready():
	hide()
	GameState.connect('score_to_win_changed_by', self, 'set_score_to_win')

func _on_ScoreInput_text_changed(new_text):
	if int(new_text) > 0 and GameState.InitParams.score_to_win != int(new_text):
		GameState.set_score_to_win(int(new_text), get_path())

func _on_Back_pressed():
	emit_signal('changed_menu', AVAILABLE_MENUES.Initial)

func _on_Local_pressed():
	Network.is_local_only = true
	GameState.start_initialization()

func set_score_to_win(new_score, edited_by):
	if edited_by == get_path():
		return
	$ScoreContainer/ScoreInput.text = str(new_score)