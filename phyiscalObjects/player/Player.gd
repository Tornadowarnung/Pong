extends 'res://phyiscalObjects/NetworkablePhysicsObject.gd'

const SPEED = 300
var is_left_side

func prepare_move(delta):
	if _can_control_network_player():
		if Input.is_action_pressed('up')\
			or Input.is_action_pressed('up_second'):
			velocity = Vector2(0, -SPEED)
		elif Input.is_action_pressed('down')\
			or Input.is_action_pressed('down_second'):
			velocity = Vector2(0, SPEED)
		else:
			velocity = Vector2(0, 0)
	elif _can_control_local_player():
		if is_left_side:
			if Input.is_action_pressed('up'):
				velocity = Vector2(0, -SPEED)
			elif Input.is_action_pressed('down'):
				velocity = Vector2(0, SPEED)
			else:
				velocity = Vector2(0, 0)
		else:
			if Input.is_action_pressed('up_second'):
				velocity = Vector2(0, -SPEED)
			elif Input.is_action_pressed('down_second'):
				velocity = Vector2(0, SPEED)
			else:
				velocity = Vector2(0, 0)

func _can_control_network_player():
	return Network._has_active_connections() and is_network_master()

func _can_control_local_player():
	return Network.is_local_only

func handle_master_after_move(delta):
	rset_unreliable('position', position)
	rset_unreliable('velocity', velocity)

func init(is_left):
	is_left_side = is_left
	if is_left:
		position = Vector2(30, 300)
	else:
		position = Vector2(get_viewport().get_visible_rect().size.x - 30 , 300)
	if !is_left:
		$Sprite.set_self_modulate(Color(0.80, 0.25, 0.25))

sync func reset():
	position.y = get_viewport_rect().size.y / 2
	velocity = Vector2(0, 0)