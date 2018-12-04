extends KinematicBody2D

const SPEED = 800.0
const PLAYER_CLASS = preload("res://player/Player.gd")

var started = false
var movement

# Networking variables
var current_time = 0.0
# slave
var curr_fraction = 0
var new_slave_pos
var old_slave_pos
var last_packet_time
var elapsed = 0.0
# master
var since_sent_pos = 0.0

slave var slave_position = Vector2()

func _ready():
	if is_network_master():
		movement = Vector2(-SPEED, 0)
		$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")

func _process(delta):
	current_time += delta

func _physics_process(delta):
	if !started:
		return
	if is_network_master():
		var collision_info = move_and_collide(movement * delta)
		
		if since_sent_pos >= Network.UPDATE_TIME:
			rpc_unreliable('_set_slave_position', position, current_time + Network.UPDATE_TIME)
			since_sent_pos = 0.0
		else:
			since_sent_pos += delta
		
		if collision_info:
			if collision_info.collider is PLAYER_CLASS:
				_collide_player(collision_info.collider, collision_info.normal, collision_info.position)
			if collision_info.collider.is_in_group("wall"):
				_collide_wall()
	else:
		if last_packet_time && old_slave_pos && new_slave_pos:
			curr_fraction = curr_fraction + (delta / elapsed)
			position = (1 - curr_fraction) * old_slave_pos + curr_fraction * new_slave_pos

remote func _set_slave_position(new_pos, master_time):
	if last_packet_time:
		elapsed = (master_time - last_packet_time)
		new_slave_pos = new_pos
		old_slave_pos = position
	last_packet_time = master_time
	curr_fraction = 0

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
	position = get_viewport_rect().size / 2
	movement = Vector2(-SPEED, 0)

func start():
	started = true
