extends Control

var _player_name = ""
var _ip_address = ""
var _port = ""

func _on_Name_text_changed(new_text):
	_player_name = new_text

func _on_IPAddress_text_changed(new_text):
	_ip_address = new_text

func _on_Port_text_changed(new_text):
	_port = new_text

func _on_CreateButton_pressed():
	if _player_name == "":
		return
	Network.create_server(_player_name)
	_load_game()

func _on_JoinButton_pressed():
	if _player_name == "":
		return
	Network.connect_to_server(_player_name)
	_load_game()

func _load_game():
	get_tree().change_scene('res://game/Game.tscn')

