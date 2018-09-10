extends Node2D

const MOVE_SPEED = 8.0
const MAX_HP = 100

enum MoveDirection { UP, DOWN, NONE }

slave var slave_position = Vector2()
slave var slave_movement = MoveDirection.NONE

var health_points = MAX_HP
var player_name

func _ready():
	_update_health_bar()

func _physics_process(delta):
	var direction = MoveDirection.NONE
	if is_network_master():
		if Input.is_action_pressed('up'):
			direction = MoveDirection.UP
		if Input.is_action_pressed('down'):
			direction = MoveDirection.DOWN

		rset_unreliable('slave_position', position)
		rset('slave_movement', direction)
		_move(direction)

	else:
		_move(slave_movement)
		position = slave_position

	if get_tree().is_network_server():
		Network.update_position(int(name), position)

func _move(direction):
	match direction:
		MoveDirection.NONE:
			return
		MoveDirection.UP:
			move_and_collide(Vector2(0, -MOVE_SPEED))
		MoveDirection.DOWN:
			move_and_collide(Vector2(0, MOVE_SPEED))

func _update_health_bar():
	return

func init(nameIn, positionIn, is_slave):
	print('Instancing player ' + nameIn)
	player_name = nameIn
	position = positionIn
	if is_slave:
		$Sprite.set_self_modulate(Color(0.80, 0.25, 0.25))
		