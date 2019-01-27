extends VBoxContainer

signal changed_menu

var AVAILABLE_MENUES = load('res://interface/available_menus.gd').AVAILABLE_MENUES

func _ready():
	hide()
	GameState.connect('ping_visible_changed', self, 'set_ping_pressed')

func _on_IPAddress_text_changed(new_text):
	Network.set_ip(new_text)

func _on_PingInput_toggled(button_pressed):
	GameState.set_ping_visible(button_pressed)

func _on_Back_pressed():
	emit_signal('changed_menu', AVAILABLE_MENUES.Initial)

func _on_Join_pressed():
	Network.connect_to_server()
	GameState.start_initialization()

func set_ping_pressed(button_pressed):
	$Pingcontainer2/PingInput.pressed = button_pressed