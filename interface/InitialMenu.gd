extends VBoxContainer

signal changed_menu

var AVAILABLE_MENUES = load('res://interface/available_menus.gd').AVAILABLE_MENUES

func _ready():
	show()

func _on_Host_pressed():
	emit_signal('changed_menu', AVAILABLE_MENUES.Host)

func _on_Join_pressed():
	emit_signal('changed_menu', AVAILABLE_MENUES.Client)

func _on_Local_pressed():
	emit_signal('changed_menu', AVAILABLE_MENUES.Local)
