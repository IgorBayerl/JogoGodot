extends Position2D

var bullet = preload("res://src/Actors/Projeteis/Bullet.tscn")

var bullet_speed = 1000
var fire_rate = 0.3
var random_rate = 0.08
var automatica = false
var damage = 0

var dir: = Vector2()
var can_fire = true
var horizontal_dir := -1


func _process(delta: float) -> void:
	
	
	if horizontal_dir > 0:
		$Arma.scale.y = -1
	else:
		$Arma.scale.y = 1
	set_direction_view()
	var Main_controller = get_tree().get_root().get_node("Main").get_node("MainController")
	if Main_controller.player_GUNS_information[Main_controller.selected_gun].ammo > 0:
		if automatica:
			if Input.is_action_pressed("shoot") and can_fire:
				
				instanciate_bullet()
				$SoundEffects/Shoot.play()
		else:
			if Input.is_action_just_pressed("shoot") and can_fire:
				instanciate_bullet()
				$SoundEffects/Shoot.play()


func get_direction() -> int:
	if Input.get_action_strength("move_LEFT") :
		horizontal_dir = 1
	if Input.get_action_strength("move_RIGHT"):
		horizontal_dir = -1
	return horizontal_dir
	
func instanciate_bullet() ->void:
	var Main_controller = get_tree().get_root().get_node("Main").get_node("MainController")
	Main_controller.atirando()
	var bullet_instance = bullet.instance()
	bullet_instance.damage = damage
	bullet_instance.position = $shooterPoint.get_global_position()
	bullet_instance.rotation_degrees = rotation_degrees + _random_value()
	bullet_instance.apply_impulse(Vector2(),Vector2(bullet_speed,0).rotated(rotation + _random_value()))
	get_tree().get_root().add_child(bullet_instance)
	can_fire = false
	yield(get_tree().create_timer(fire_rate), "timeout")
	can_fire = true

func _random_value()-> float:
	var _random_shoot_value = 0
	_random_shoot_value = rand_range( -random_rate , random_rate )
	return _random_shoot_value
	
func set_direction_view() -> void:
	
	if get_direction() < 0:
		dir = Vector2(0, 0)
	if get_direction() > 0:
		dir = Vector2(-1, 0)
		
	if (get_direction() > 0 
	and (Input.is_action_pressed("move_UP") or Input.is_action_pressed("move_DOWN")) 
	and !Input.is_action_pressed("move_LEFT")):
		dir = Vector2(0, 0)
	
	if Input.is_action_pressed("move_RIGHT") :
		dir += Vector2(1 , 0)
	
	if Input.is_action_pressed("move_DOWN"):
		dir.y += 1
		
	if Input.is_action_just_released("move_DOWN"):
		dir += Vector2(dir.x , 0)
		
	if Input.is_action_pressed("move_UP"):
		dir.y += -1
		
	if Input.is_action_just_released("move_UP"):
		dir += Vector2(dir.x , 0)
		
	
	
#	print( dir )
	rotation = dir.angle()
	
	
	
