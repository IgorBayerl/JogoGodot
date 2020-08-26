extends KinematicBody2D

onready var Player = get_parent().get_node("Player")

var atacking = false

var vel = Vector2(0, 0)
var LOOKING_DIRECTION = Vector2( 1 , 0 )

var grav = 1800
var max_grav = 3000

var react_time = 100
var dir = 0
var next_dir = 0
var next_dir_time = 0

var next_jump_time = -1

var target_player_dist = 140

var eye_reach = 90
var vision = 600

func _ready():
	set_process(true)

func set_dir(target_dir):
	if next_dir != target_dir:
		next_dir = target_dir
		next_dir_time = OS.get_ticks_msec() + react_time

func sees_player():
	var eye_center = get_global_position()
	var eye_top = eye_center + Vector2(0, -eye_reach)
	var eye_left = eye_center + Vector2(-eye_reach, 0)
	var eye_right = eye_center + Vector2(eye_reach, 0)

	var player_pos = Player.get_global_position()
	var player_extents = Player.get_node("Colision").shape.extents - Vector2(1, 1)
	var top_left = player_pos + Vector2(-player_extents.x, -player_extents.y)
	var top_right = player_pos + Vector2(player_extents.x, -player_extents.y)
	var bottom_left = player_pos + Vector2(-player_extents.x, player_extents.y)
	var bottom_right = player_pos + Vector2(player_extents.x, player_extents.y)

	var space_state = get_world_2d().direct_space_state

	for eye in [eye_center, eye_top, eye_left, eye_right]:
		for corner in [top_left, top_right, bottom_left, bottom_right]:
			if (corner - eye).length() > vision:
				continue
			var collision = space_state.intersect_ray(eye, corner, [], 4) # collision mask = sum of 2^(collision layers) - e.g 2^0 + 2^3 = 9
			if collision and collision.collider.name == "Player":
				return true
	return false

func _process(delta):
	
	$AnimatedSprite.scale.x = LOOKING_DIRECTION.x
	if not atacking:
		if Player.position.x < position.x - target_player_dist and sees_player() :
			set_dir(-1)
			LOOKING_DIRECTION = Vector2(1,0)
			$AnimatedSprite.play("Walk")
			
		elif Player.position.x > position.x + target_player_dist and sees_player() :
			set_dir(1)
			LOOKING_DIRECTION = Vector2(-1,0)
			$AnimatedSprite.play("Walk")
		else :
			set_dir(0)
			$AnimatedSprite.play("Idle")
	else:
		$AnimatedSprite.play("Atack")

	if OS.get_ticks_msec() > next_dir_time:
		dir = next_dir

	if OS.get_ticks_msec() > next_jump_time and next_jump_time != -1 and is_on_floor():
		if Player.position.y < position.y - 64 and sees_player():
			vel.y = -800
		next_jump_time = -1

	vel.x = dir * 275

	if Player.position.y < position.y - 64 and next_jump_time == -1 and sees_player():
		next_jump_time = OS.get_ticks_msec() + react_time

	vel.y += grav * delta;
	if vel.y > max_grav:
		vel.y = max_grav

	if is_on_floor() and vel.y > 0:
		vel.y = 0

	vel = move_and_slide(vel, Vector2(0, -1))

func take_damage():
	print('outch !!! tomei um dano aqui !')



func _on_Trigger_area_entered(area: Area2D) -> void:
	print ('atack')
	atacking = true
	$AnimatedSprite.play("atack")
	$AnimatedSprite/HitBox/AnimationPlayer.play("Hit")
	yield(get_tree().create_timer(0.5), "timeout")
	atacking = false
