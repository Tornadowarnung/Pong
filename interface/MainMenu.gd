extends Control

enum AVAILABLE_MENUES{
	Initial,
	Host,
	Client
}

var _player_name = ""
var _ip_address = ""
var _winning_score = 3
var current_menu = AVAILABLE_MENUES.Initial

func _ready():
	_change_menu_to(current_menu)

func _on_Name_text_changed(new_text):
	_player_name = new_text

func _on_IPAddress_text_changed(new_text):
	_ip_address = new_text
	Network.set_ip(_ip_address)

func _on_CreateButton_pressed():
	if _player_name == "":
		$InitialMenu/NameContainer/WarningContainer/NameWarning.show()
		return
	_change_menu_to(AVAILABLE_MENUES.Host)

func _on_JoinButton_pressed():
	if _player_name == "":
		$InitialMenu/NameContainer/WarningContainer/NameWarning.show()
		return
	_change_menu_to(AVAILABLE_MENUES.Client)

func _create_server():
	Network.create_server(_player_name)
	_load_game()

func _join_server():
	Network.connect_to_server(_player_name)
	_load_game()

func _on_Back_pressed():
	_change_menu_to(AVAILABLE_MENUES.Initial)

func _load_game():
	var Game = load('res://game/Game.tscn').instance()
	Game.score_to_win = _winning_score
	get_tree().get_root().add_child(Game)
	hide()

func _change_menu_to(menu):
	match menu:
		AVAILABLE_MENUES.Host:
			print("switching to host menu...")
			_hide_all_menues()
			current_menu = menu
			$HostMenu.show()
		AVAILABLE_MENUES.Initial:
			print("switching to initial menu...")
			_hide_all_menues()
			current_menu = menu
			$InitialMenu.show()
		AVAILABLE_MENUES.Client:
			print("switching to client menu...")
			_hide_all_menues()
			current_menu = menu
			$ClientMenu.show()
		_:
			printerr("Can't switch to menu ", menu, " because it is not valid!")

func _hide_all_menues():
	for menu in get_children():
		menu.hide()


func _on_ScoreInput_text_changed(new_text):
	if int(new_text) > 0:
		_winning_score = int(new_text)
