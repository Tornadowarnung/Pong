extends Node2D

var active = false

var velocity = Vector2(0, 0)

func _ready():
	Network.connect('ticked', self, '_on_network_tick')
	rset_config('position', RPC_MODE_REMOTE)
	rset_config('velocity', RPC_MODE_REMOTE)

func _physics_process(delta):
	if !active:
		return
	prepare_move(delta)
	var collision = move(delta)
	if collision:
		handle_collision(collision)
	if Network._has_active_connections() and is_network_master():
		handle_master_after_move(delta)
	else:
		handle_slave_after_move(delta)

func prepare_move(delta):
	pass

func move(delta):
	return move_and_collide(velocity * delta)

func handle_collision(collision):
	pass

func handle_master_after_move(delta):
	pass

func handle_slave_after_move(delta):
	pass

func _on_network_tick():
	if Network._has_active_connections() and is_network_master():
		rset_unreliable('position', position)
		rset_unreliable('velocity', velocity)

func start():
	active = true

func stop():
	active = false

sync func reset():
	print('ERROR: reset should not be called but instead be overriden by the extending scenes')