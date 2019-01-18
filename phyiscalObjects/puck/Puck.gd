extends 'res://phyiscalObjects/NetworkablePhysicsObject.gd'

signal scored_goal

const SPEED = 800.0
const PLAYER_CLASS = preload("res://phyiscalObjects/player/Player.gd")

var movement

func _ready():
#	._ready()
	if is_network_master():
		movement = Vector2(-SPEED, 0)
		$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")
	else:
		$CollisionShape2D.set_disabled(true)

func master_movement(delta):
	var collision_info = move_and_collide(movement * delta)
	if collision_info:
		if collision_info.collider is PLAYER_CLASS:
			_collide_player(collision_info.collider, collision_info.normal, collision_info.position)
		if collision_info.collider.is_in_group("wall"):
			_collide_wall()

func _collide_player(player, normal, pos):
	movement.x = movement.x * -1
	movement.y = movement.y + (pos.y - player.position.y) * 15
	_normalize_speed()

func _collide_wall():
	movement.y = -movement.y
	_normalize_speed()

func _normalize_speed():
	var remainder = SPEED / movement.length()
	movement = movement * remainder

func _on_screen_exited():
	emit_signal("scored_goal", position.x > get_viewport_rect().size.x)
	position = get_viewport_rect().size / 2
	movement = Vector2(-SPEED, 0)