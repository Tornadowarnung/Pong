extends KinematicBody2D

const SPEED = 80.0

func _ready():
	pass

func _physics_process(delta):
		move_and_collide(Vector2(-SPEED * delta, 0))