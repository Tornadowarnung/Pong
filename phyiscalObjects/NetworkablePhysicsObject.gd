extends Node2D

var active = false

var Interpolation = {
		# Networking variables
	current_time = 0.0,
	# slave
	curr_fraction = 0,
	new_slave_pos = Vector2(),
	old_slave_pos = Vector2(),
	last_packet_time = 0,
	elapsed = 0.0
}

func _ready():
	Network.connect('ticked', self, '_on_network_tick')

func _process(delta):
	if !active:
		return
	Interpolation.current_time += delta

func _physics_process(delta):
	if !active:
		return
	before_movement(delta)
	if is_network_master():
		master_movement(delta)
	else:
		slave_movement(delta)

func before_movement(delta):
	pass

func master_movement(delta):
	print('ERROR: master_movement should not be called but instead be overriden by the extending scenes')

func slave_movement(delta):
	if Interpolation.last_packet_time && Interpolation.old_slave_pos && Interpolation.new_slave_pos:
		if Interpolation.elapsed != 0:
			Interpolation.curr_fraction = Interpolation.curr_fraction + (delta / Interpolation.elapsed)
		else:
			Interpolation.curr_fraction = Interpolation.curr_fraction + delta * 100
		position = (1 - Interpolation.curr_fraction) * Interpolation.old_slave_pos + Interpolation.curr_fraction * Interpolation.new_slave_pos

func _on_network_tick():
	if Network._has_active_connections():
		rpc_unreliable('_set_slave_position', position, Interpolation.current_time + Network.UPDATE_TIME)

remote func _set_slave_position(new_pos, master_time):
	Interpolation.elapsed = (master_time - Interpolation.last_packet_time)
	Interpolation.new_slave_pos = new_pos
	Interpolation.old_slave_pos = position
	Interpolation.last_packet_time = master_time
	Interpolation.curr_fraction = 0

func start():
	active = true

func stop():
	active = false

func reset():
	print('ERROR: reset should not be called but instead be overriden by the extending scenes')