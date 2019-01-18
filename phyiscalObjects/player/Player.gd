extends 'res://phyiscalObjects/NetworkablePhysicsObject.gd'

const MOVE_SPEED = 8.0

enum MoveDirection { UP, DOWN, NONE }

var direction = MoveDirection.NONE
var player_name

func is_master():
	is_network_master()

func before_movement(delta):
	direction = MoveDirection.NONE

func master_movement(delta):
	if Input.is_action_pressed('up'):
		direction = MoveDirection.UP
	if Input.is_action_pressed('down'):
		direction = MoveDirection.DOWN
	_move(direction)

func _move(direction):
	match direction:
		MoveDirection.NONE:
			return
		MoveDirection.UP:
			move_and_collide(Vector2(0, -MOVE_SPEED))
		MoveDirection.DOWN:
			move_and_collide(Vector2(0, MOVE_SPEED))

func init(nameIn, positionIn, is_slave):
	player_name = nameIn
	position = positionIn
	if is_slave:
		$Sprite.set_self_modulate(Color(0.80, 0.25, 0.25))

func reset():
	position.y = 300