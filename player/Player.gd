extends Node2D

var player_name

func init(nameIn, positionIn, someboolean):
	player_name = nameIn
	position = positionIn
	$CenterContainer/Label.text = player_name