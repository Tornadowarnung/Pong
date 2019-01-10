extends Control

var _player_name = ""
var _ip_address = ""

func _on_Name_text_changed(new_text):
	_player_name = new_text

func _on_IPAddress_text_changed(new_text):
	_ip_address = new_text
	Network.set_ip(_ip_address)

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
	var Game = load('res://game/Game.tscn').instance()
	get_tree().get_root().add_child(Game)
	hide()

