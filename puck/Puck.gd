extends KinematicBody2D

const SPEED = 800.0
const PLAYER_CLASS = preload("res://player/Player.gd")

var movement

slave var slave_position = Vector2()

func _ready():
	if is_network_master():
		movement = Vector2(-SPEED, 0)
		$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")

func _physics_process(delta):
	if is_network_master():
		var collision_info = move_and_collide(movement * delta)
		rset_unreliable('slave_position', position)
		if collision_info:
			if collision_info.collider is PLAYER_CLASS:
				_collide_player(collision_info.collider, collision_info.normal, collision_info.position)
			if collision_info.collider.is_in_group("wall"):
				_collide_wall()
	else:
		position = slave_position
	

func _collide_player(player, normal, pos):
	movement.x = movement.x * -1
	movement.y = movement.y + (pos.y - player.position.y) * 15

func _collide_wall():
	movement.y = -movement.y

func _on_screen_exited():
	position = get_viewport_rect().size / 2
	movement = Vector2(-SPEED, 0)