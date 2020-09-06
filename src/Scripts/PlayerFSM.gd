extends KinematicBody2D


export var GRAVITY = 1200

signal OnDeath(WhoDied)

const UP = Vector2(0, -1)
const SLOPE_STOP = 60
const WALL_JUMP_VELOCITY = Vector2(400 , -500)

var can_dash = true

####################
var move_speed = 300

var velocity = Vector2()
var move_direction
var move_input_speed = 0
var facing = 1
var wall_direction = 1
var max_health = 100
var health = 100
var wal_jumping = false
var head_direction = Vector2()
var rolling_speed = 400

var atack_combo = 0
var can_atack = true

var max_jump_velocity = -600
var min_jump_velocity = -400


# STATES #

var is_jumping = false
var is_grounded = false
var is_wall_sliding = false
var is_dead = false
var is_atacking = false
var is_rolling = false
var is_crouched = false



############

onready var anim_player = $SPRITES/AnimationPlayer
onready var player_body = $SPRITES

onready var left_wall_raycasts = $WallRaycast/LeftWallRaycast
onready var right_wall_raycasts = $WallRaycast/RightWallRaycast

onready var wall_slide_sticky_timer = $WallSlideSticknesTimer

func _apply_gravity(delta):
	velocity.y += GRAVITY * delta
	if is_jumping and velocity.y >=0:
		is_jumping = false
	
func _cap_gravity_wall_slide():
	var max_velocity = 96
	velocity.y = min(velocity.y, max_velocity)
	
func _handle_wall_slide_sticking():
	if move_direction !=0 and move_direction != wall_direction:
		if wall_slide_sticky_timer.is_stopped():
			wall_slide_sticky_timer.start()
	else:
		wall_slide_sticky_timer.stop()
	
func _wall_jump():
	var wall_jump_velocity = WALL_JUMP_VELOCITY
	wall_jump_velocity.x *= -wall_direction
	velocity = wall_jump_velocity
	wal_jumping = true
	$WalljumpMovementBlocker.start()
	
func _apply_movement():
	velocity = move_and_slide(velocity, UP,SLOPE_STOP)
	
func _update_move_direction():
	move_direction = -int(Input.is_action_pressed("move_LEFT")) + int(Input.is_action_pressed("move_RIGHT"))
	
func _handle_move_input():
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())
	if move_direction != 0:
		player_body.scale.x = move_direction
		facing = move_direction
	
func _get_h_weight():
	if is_on_floor():
		return 0.2
	else:
		if move_direction == 0:
			return 0.02
		elif move_direction == sign(velocity.x) and abs(velocity.x) > move_speed:
			return 0.0
		else:
			return 0.1
	
func _update_wall_direction():
	var is_near_wall_left = _check_is_valid_wall(left_wall_raycasts)
	var is_near_wall_right = _check_is_valid_wall(right_wall_raycasts)
	
	if is_near_wall_left and is_near_wall_right:
		wall_direction = move_direction
	else:
		wall_direction = -int(is_near_wall_left) + int(is_near_wall_right)
	
func _check_is_valid_wall(wall_raycasts):
	for raycast in wall_raycasts.get_children():
		if raycast.is_colliding():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 and dot < PI * 0.55:
				return true
	return false
	
func _set_head_direction():
	head_direction.x = 1.5
	head_direction.y = -int(Input.is_action_pressed("move_DOWN")) + int(Input.is_action_pressed("move_UP"))
	$SPRITES/Head.rotation = -head_direction.angle()
	
func _roll():
	velocity.x = facing * rolling_speed

func _rolling_direction():
	if $Roll_Timer.is_stopped():
		print('_rolling(direction)')
		$Roll_Timer.start()
		is_rolling = true

func _atack():
	if can_atack:
		if atack_combo == 0 and can_atack and not is_atacking:
			print("atack 0 --> 1")
			atack_combo = 1
			is_atacking = true
			can_atack = false
			$MiliAtack_Timer.start()
		if atack_combo == 1 and can_atack and is_atacking:
			print("atack 1 --> 2")
			atack_combo = 2
			is_atacking = true
			can_atack = false
			$MiliAtack_Timer.start()


	print("atack_combo = ", atack_combo)

func _update_lebel_state(state, previous_state):
	$state_label.text = str(state)

func _atack_combo():
	$MiliAtack_Timer.start()
	if is_atacking == true:
		if atack_combo == 1:
			anim_player.play("Atack1")
		elif atack_combo == 2:
			anim_player.play("Atack2")

		
func camera_shake(timeout):
	$Mira/Camera_position/Camera2D.shake = true
	yield(get_tree().create_timer(timeout), "timeout")
	$Mira/Camera_position/Camera2D.shake = false
	
func take_damage(damage):
	get_parent().get_node("CanvasLayer/Control/Health Bar").take_damage(damage)
	health -= damage
	death_detection()
	
func death_detection():
	if health <= 0 and not is_dead:
		is_dead = true
		emit_signal("OnDeath",self)


################## DASH ###################

func dash():
	$Dash_sound.play()
	is_rolling = true
	can_dash = false

	move_speed = 1000
	$Dash.visible = false
############################################
func _on_Ghost_Timer_timeout() -> void:
	pass
#	if is_dashing:
#		var this_ghost = preload("res://src/Actors/Efeitos/ghost.tscn").instance()
#		get_parent().add_child(this_ghost)
#		this_ghost.position = position + Vector2(0,20)
#		this_ghost.texture = $SPRITES/body.frames.get_frame($SPRITES/body.animation, $SPRITES/body.frame)
###########################################
#func animations_set():
#
#	######## MILI ATACK ########
#	if is_atacking != 0:
#		$Mira/Arma.visible = false
#		$Mira.can_fire = false
#	else:
#		if Input.is_action_just_pressed("shoot"):
#			$Mira.can_fire = true
#		$Mira/Arma.visible = true
#
#
#	if Input.is_action_just_pressed("interact") and is_atacking == 0 :
#		is_atacking = 1
#		yield(get_tree().create_timer(0.5), "timeout")
#		if is_atacking == 1:
#			is_atacking = 0
#	if Input.is_action_just_pressed("interact") and is_atacking == 1:
#		is_atacking = 2
#		yield(get_tree().create_timer(0.6), "timeout")
#		if is_atacking == 2:
#			is_atacking = 0
#	if Input.is_action_just_pressed("interact") and is_atacking == 2 :
#		is_atacking = 1
#		yield(get_tree().create_timer(0.5), "timeout")
#		if is_atacking == 1:

func _on_MiliAtack_Timer_timeout():
	can_atack = true
	print("can atack == true")

func _on_SwordHit_body_entered(body: Node) -> void:
	if body.is_in_group("Entidade"):
		$Mira/Camera_position/Camera2D.shake = true
		var damage = rand_range(30, 30)
		if facing == 1:
			body.take_damage(damage, 0)
		if facing == -1:
			body.take_damage(damage, 180)
		yield(get_tree().create_timer(0.2), "timeout")
		$Mira/Camera_position/Camera2D.shake = false

func _on_WalljumpMovementBlocker_timeout() -> void:
	wal_jumping = false

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Atack1":
		is_atacking = false



func _on_Roll_Timer_timeout() -> void:
	is_rolling = false
