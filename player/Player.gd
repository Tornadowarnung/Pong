extends Node2D

const MOVE_SPEED = 8.0
const MAX_HP = 100

enum MoveDirection { UP, DOWN, NONE }

var active = false

var health_points = MAX_HP
var player_name

# Networking variables
var current_time = 0.0
# slave
var curr_fraction = 0
var new_slave_pos
var old_slave_pos
var last_packet_time
var elapsed = 0.0

func _ready():
	Network.connect('ticked', self, '_on_network_tick')

func _process(delta):
	if !active:
		return
	current_time += delta

func _physics_process(delta):
	if !active:
		return
	var direction = MoveDirection.NONE
	if is_network_master():
		if Input.is_action_pressed('up'):
			direction = MoveDirection.UP
		if Input.is_action_pressed('down'):
			direction = MoveDirection.DOWN

		_move(direction)
	else:
		if last_packet_time && old_slave_pos && new_slave_pos:
			if elapsed != 0:
				curr_fraction = curr_fraction + (delta / elapsed)
			else:
				curr_fraction = curr_fraction + delta * 100
			position = (1 - curr_fraction) * old_slave_pos + curr_fraction * new_slave_pos

func _on_network_tick():
	if Network._has_active_connections():
		rpc_unreliable('_set_slave_position', position, current_time + Network.UPDATE_TIME)

remote func _set_slave_position(new_pos, master_time):
	if last_packet_time:
		elapsed = (master_time - last_packet_time)
		new_slave_pos = new_pos
		old_slave_pos = position
	last_packet_time = master_time
	curr_fraction = 0

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

sync func start():
	active = true