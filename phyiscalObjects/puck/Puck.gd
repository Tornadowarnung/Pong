extends 'res://phyiscalObjects/NetworkablePhysicsObject.gd'

signal scored_goal

const SPEED = 800.0
const PLAYER_CLASS = preload("res://phyiscalObjects/player/Player.gd")

func _ready():
	velocity = Vector2(-SPEED, 0)
	if Network.is_network_master_of(self):
		$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")

func handle_collision(collision_info):
	if collision_info.collider is PLAYER_CLASS:
		_collide_player(collision_info.collider, collision_info.normal, collision_info.position)
	if collision_info.collider.is_in_group("wall"):
		_collide_wall()

remote func _collide_player(player, normal, pos):
	velocity.x = velocity.x * -1
	velocity.y = velocity.y + (pos.y - player.position.y) * 15
	velocity.y = clamp(velocity.y, -700, 700)
	_normalize_speed()
	_update_remote()

remote func _collide_wall():
	velocity.y = -velocity.y
	_normalize_speed()
	_update_remote()

func _update_remote():
	if Network._has_active_connections() and is_network_master():
		rset_unreliable('position', position)
		rset_unreliable('velocity', velocity)

func _normalize_speed():
	var remainder = SPEED / velocity.length()
	velocity = velocity * remainder

func _on_screen_exited():
	emit_signal("scored_goal", position.x > get_viewport_rect().size.x)
	if Network._has_active_connections():
		rpc("reset")
	if Network.is_local_only:
		reset()

sync func reset():
	position = get_viewport_rect().size / 2
	velocity = Vector2(-SPEED, 0)