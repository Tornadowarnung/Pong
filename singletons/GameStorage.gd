extends Node

func _ready():
	rset_config('score_to_win', Node.RPC_MODE_SLAVE)

var score_to_win = 3
var ping_visible = false