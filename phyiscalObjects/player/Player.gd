extends 'res://phyiscalObjects/NetworkablePhysicsObject.gd'

const SPEED = 300

func prepare_move(delta):
	if Network._has_active_connections() and is_network_master():
		if Input.is_action_pressed('up'):
			velocity = Vector2(0, -SPEED)
		elif Input.is_action_pressed('down'):
			velocity = Vector2(0, SPEED)
		else:
			velocity = Vector2(0, 0)

func handle_master_after_move(delta):
	rset_unreliable('position', position)
	rset_unreliable('velocity', velocity)

func init(is_left):
	if is_left:
		position = Vector2(30, 300)
	else:
		position = Vector2(get_viewport().get_visible_rect().size.x - 30 , 300)
	if !is_network_master():
		$Sprite.set_self_modulate(Color(0.80, 0.25, 0.25))

sync func reset():
	position.y = get_viewport_rect().size.y / 2
	velocity = Vector2(0, 0)