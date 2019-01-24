extends Control

enum AVAILABLE_MENUES{
	Initial,
	Host,
	Client,
	Local
}

var _ip_address = ""
var current_menu = AVAILABLE_MENUES.Initial

func _ready():
	GameState.connect('started_initialization', self, 'hide')
	GameState.connect('returned_to_menu', self, 'show')
	_change_menu_to(current_menu)

func _on_IPAddress_text_changed(new_text):
	_ip_address = new_text
	Network.set_ip(_ip_address)

func _on_CreateButton_pressed():
	_change_menu_to(AVAILABLE_MENUES.Host)

func _on_JoinButton_pressed():
	_change_menu_to(AVAILABLE_MENUES.Client)

func _on_LocalButton_pressed():
	_change_menu_to(AVAILABLE_MENUES.Local)

func _create_server():
	Network.create_server()
	GameState.start_initialization()

func _join_server():
	Network.connect_to_server()
	GameState.start_initialization()

func _start_local():
	Network.is_local_only = true
	GameState.start_initialization()

func _on_Back_pressed():
	_change_menu_to(AVAILABLE_MENUES.Initial)

func _change_menu_to(menu):
	match menu:
		AVAILABLE_MENUES.Host:
			_hide_all_menues()
			current_menu = menu
			$HostMenu.show()
		AVAILABLE_MENUES.Initial:
			_hide_all_menues()
			current_menu = menu
			$InitialMenu.show()
		AVAILABLE_MENUES.Client:
			_hide_all_menues()
			current_menu = menu
			$ClientMenu.show()
		AVAILABLE_MENUES.Local:
			_hide_all_menues()
			current_menu = menu
			$LocalMenu.show()
		_:
			printerr("Can't switch to menu ", menu, " because it is not valid!")

func _hide_all_menues():
	for menu in get_children():
		menu.hide()

func _on_ScoreInput_text_changed(new_text):
	if int(new_text) > 0:
		GameState.InitParams.score_to_win = int(new_text)
	if $LocalMenu/ScoreContainer/ScoreInput.text != new_text:
		$LocalMenu/ScoreContainer/ScoreInput.text = new_text
	if $HostMenu/ScoreContainer/ScoreInput.text != new_text:
		$HostMenu/ScoreContainer/ScoreInput.text = new_text

func _on_PingInput_toggled(button_pressed):
	GameState.Settings.ping_visible = button_pressed
	$ClientMenu/Pingcontainer2/PingInput.pressed = button_pressed
	$HostMenu/Pingcontainer/PingInput.pressed = button_pressed
