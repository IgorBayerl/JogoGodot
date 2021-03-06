extends KinematicBody2D


export var GRAVITY = 1200

signal OnDeath(WhoDied)
signal OnRespawn(WhoDied)

const UP = Vector2(0, -1)
const SLOPE_STOP = 60
const WALL_JUMP_VELOCITY = Vector2(400 , -500)

####################

var checkpoint_position: Vector2

var move_speed = 210
var velocity = Vector2()
var move_direction
var move_input_speed = 0
var facing = 1
var wall_direction = 1
var max_health = 100
var health = 100
var wal_jumping = false
var head_direction = Vector2()
var rolling_speed = 500
var jump_count = 0

var can_stand_up = true
var atack_combo = 0
var can_atack = true
var can_access_inventory = false
var can_climb_up = false

var max_jump_velocity = -450
var min_jump_velocity = -300
var double_jump_velocity = -300

# Skills control #

var have_double_jump = true
var have_wall_jump = true
var have_rolling = false
var have_heavy_gun = false

# STATES #

var is_jumping = false
var is_grounded = false
var is_wall_sliding = false
var is_dead = false
var is_atacking = false
var is_rolling = false
var is_crouched = false
var is_stuned = false
var is_clibing_up = false
var is_wall_grab = false

var in_menu = false

############

onready var anim_player = $SPRITES/AnimationPlayer
onready var player_body = $SPRITES
onready var left_wall_raycasts = $WallRaycast/LeftWallRaycast
onready var right_wall_raycasts = $WallRaycast/RightWallRaycast

onready var right_climb_up_raycast = $WallRaycast/ClimbUpRaycasts/ClimbUpRight
onready var left_climb_up_raycast = $WallRaycast/ClimbUpRaycasts/ClimbUpLeft
onready var DW_right_climb_up_raycast = $WallRaycast/ClimbUpRaycasts/DW_ClimbUpRight
onready var DW_left_climb_up_raycast = $WallRaycast/ClimbUpRaycasts/DW_ClimbUpLeft

onready var wall_slide_sticky_timer = $WallSlideSticknesTimer
onready var anim_effect = $Effects_animationPlayer
onready var ivunerability = $Ivunerability

onready var particles_wall_slide1 = $SPRITES/Particles2D
onready var particles_wall_slide2 = $SPRITES/Particles2D2

onready var playerColisionBox = $CollisionShape2D
onready var Camera = $PlayerStructure/Mira/Eixo/CameraPosition/Camera2D
onready var teto_detection = $WallRaycast/tetoDetection_1




func _check_if_can_climb_up():
	if wall_direction != 0:
		if wall_direction == 1:
			if right_climb_up_raycast.is_colliding() and DW_right_climb_up_raycast.is_colliding():
				print('can climb up == true')
				return true
			elif right_climb_up_raycast.is_colliding():
				print('can climb up == false')
				return false
		if wall_direction == -1:
			if left_climb_up_raycast.is_colliding() and DW_left_climb_up_raycast.is_colliding():
				print('can climb up == true')
				return true
			elif left_climb_up_raycast.is_colliding():
				print('can climb up == false')
				return false

func _check_if_can_wall_grab():
	if wall_direction != 0:
		if wall_direction == 1:
			if !right_climb_up_raycast.is_colliding() and DW_right_climb_up_raycast.is_colliding():
#				print('can wall grab == true')
				is_wall_grab = true
				return true
			elif right_climb_up_raycast.is_colliding():
#				print('can wall grab == false')
				is_wall_grab = false
				return false
		if wall_direction == -1:
			if !left_climb_up_raycast.is_colliding() and DW_left_climb_up_raycast.is_colliding():
#				print('can wall grab == true')
				is_wall_grab = true
				return true
			elif left_climb_up_raycast.is_colliding():
#				print('can wall grab == false')
				is_wall_grab = false
				return false

func _climb_up():
#	position = Vector2(position.x + (30 * wall_direction),position.y - 80)
	print('Climb up action')
	var climb_direction = wall_direction
#	velocity.y = -800
	velocity.y += -800 
	yield(get_tree().create_timer(0.2), "timeout")
	velocity.x = 290 * climb_direction
	velocity.y = 0
	
	is_clibing_up = false
	is_wall_grab = false

#func _climb_up():
##	position = Vector2(position.x + (30 * wall_direction),position.y - 80)
#	print('ooooooooooo')
#	var climb_direction = wall_direction
#	velocity.y = -460
#	yield(get_tree().create_timer(0.2), "timeout")
#	velocity.x = 290 * climb_direction
#	velocity.y = 0
#
#	is_clibing_up = false
#	is_wall_grab = false

func _turning_on_skills():
	if Input.is_key_pressed(KEY_J):
		have_double_jump = !have_double_jump
		print('double_jump = ', have_double_jump)

func _apply_gravity(delta):
	if !is_wall_grab and !is_clibing_up:
		velocity.y += GRAVITY * delta

	if is_jumping and velocity.y >=0:
		is_jumping = false

func _cap_gravity_wall_slide():
#	if !Input.is_action_pressed("move_DOWN"):
#		var max_velocity = 96
#		velocity.y = min(velocity.y, max_velocity)
	var max_velocity = 0
	velocity.y = min(velocity.y, max_velocity)

func _handle_wall_slide_sticking():
	if move_direction !=0 and move_direction != wall_direction:
		if wall_slide_sticky_timer.is_stopped():
			wall_slide_sticky_timer.start()
	else:
		wall_slide_sticky_timer.stop()


# Dano dano
#func _unhandled_input(event):
#	if event.is_action_pressed("ui_accept"):
#		take_damage(80)
		
func _wall_jump():
	var wall_jump_velocity = WALL_JUMP_VELOCITY
	wall_jump_velocity.x *= -wall_direction
	velocity = wall_jump_velocity
	wal_jumping = true
	$WalljumpMovementBlocker.start()

func _apply_movement():
	velocity = move_and_slide(velocity, UP,SLOPE_STOP)

func _update_move_direction():
	if !is_wall_grab and !is_clibing_up:
		move_direction = -int(Input.is_action_pressed("move_LEFT")) + int(Input.is_action_pressed("move_RIGHT"))
	if is_wall_grab or is_clibing_up :
		move_direction = -wall_direction
func _handle_move_input():
	velocity.x = lerp(velocity.x, move_speed * move_direction, _get_h_weight())

func _update_sprite_direction():
	
	if move_direction != 0:
		player_body.scale.x = move_direction
		facing = move_direction

func _get_h_weight():
	if is_on_floor():
		return 0.6
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
	var raycast_up = wall_raycasts.get_child(0)
	var raycast_down = wall_raycasts.get_child(1)
	if raycast_down.is_colliding() and raycast_up.is_colliding():
		for raycast in wall_raycasts.get_children():
			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
			if dot > PI * 0.35 and dot < PI * 0.55:
				return true
#	for raycast in wall_raycasts.get_children():
#
#		if raycast.is_colliding():
#			var dot = acos(Vector2.UP.dot(raycast.get_collision_normal()))
#			if dot > PI * 0.35 and dot < PI * 0.55:
#				return true
	return false

func _set_head_direction():
	head_direction.x = 1.5
	head_direction.y = -int(Input.is_action_pressed("move_DOWN")) + int(Input.is_action_pressed("move_UP"))
	$SPRITES/Head.rotation = -head_direction.angle()

func _roll():
	velocity.x = facing * rolling_speed

func _rolling_direction():
	if $Roll_Timer.is_stopped():
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
	$SPRITES/Mira/Camera_position/Camera2D.shake = true
	yield(get_tree().create_timer(timeout), "timeout")
	$SPRITES/Mira/Camera_position/Camera2D.shake = false

func take_damage(damage):
	if ivunerability.is_stopped() and not is_dead:
		if !is_rolling:
			is_stuned = true
			ivunerability.start()
			get_parent().get_node("CanvasLayer/Control/Health Bar").take_damage(damage)
			health -= damage
			death_detection()

func death_detection():
	if health <= 0 and not is_dead:
		is_dead = true
		emit_signal("OnDeath",self)
		yield(get_tree().create_timer(2.5), "timeout")
		_respawn()

func _update_effect_animation():
	if is_stuned:
		anim_effect.play("piscando")
	else:
		anim_effect.play("normal")

func _respawn():
	
	
	yield(get_tree().create_timer(1), "timeout")
	position = checkpoint_position
	health = max_health
	is_dead = false
	emit_signal("OnRespawn",self)
	get_parent().get_node("CanvasLayer/Control/Health Bar").restore_health()

func _atack_finish():
	is_atacking = false

func _on_MiliAtack_Timer_timeout():
	can_atack = true

func _on_SwordHit_body_entered(body: Node) -> void:
	if body.is_in_group("Entidade"):
#		Camera.shake = true
		var damage = rand_range(30, 30)
		if facing == 1:
			body.take_damage(damage, 0)
		if facing == -1:
			body.take_damage(damage, 180)
		yield(get_tree().create_timer(0.2), "timeout")
#		Camera.shake = false

func _on_WalljumpMovementBlocker_timeout() -> void:
	wal_jumping = false

func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Atack1":
		is_atacking = false

func _on_Roll_Timer_timeout() -> void:
	is_rolling = false
	_verify_if_can_standup()

func _on_Ivunerability_timeout() -> void:
	is_stuned = false

func _on_Area2D_body_entered(body: Node) -> void:
	have_double_jump = true

func _on_tetoDetection_1_body_entered(body):
	can_stand_up = false
	print('tem teto aqui caraio')
func _on_tetoDetection_1_body_exited(body):
	can_stand_up = true
	print('não tem teto não')
	_verify_if_can_standup()


func _verify_if_can_standup():
	if can_stand_up and !Input.is_action_pressed("ctrl"):
		is_crouched = false
	elif !can_stand_up:
		is_crouched = true


func can_access_inventory(can_access):
	if can_access != null :
		can_access_inventory = can_access
	else:
		can_access_inventory = false
	print("[ _can_access_inventory ] : ", can_access)



