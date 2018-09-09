extends Node2D

const MOVE_SPEED = 10.0
const MAX_HP = 100

enum MoveDirection { UP, DOWN, LEFT, RIGHT, NONE }

slave var slave_position = Vector2()
slave var slave_movement = MoveDirection.NONE

var health_points = MAX_HP
var player_name

func _ready():
	_update_health_bar()

func _physics_process(delta):
	var direction = MoveDirection.NONE
	if is_network_master():
		if Input.is_action_pressed('left'):
			direction = MoveDirection.LEFT
		if Input.is_action_pressed('right'):
			direction = MoveDirection.RIGHT
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
		MoveDirection.LEFT:
			move_and_collide(Vector2(-MOVE_SPEED, 0))
		MoveDirection.RIGHT:
			move_and_collide(Vector2(MOVE_SPEED, 0))

func _update_health_bar():
	return

func init(nameIn, positionIn, is_slave):
	print('Instancing player ' + nameIn)
	player_name = nameIn
	position = positionIn
	$CenterContainer/Label.text = player_name
	if is_slave:
		$Sprite.texture = load('res://icon-alt.png')