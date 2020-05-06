extends entity
class_name player
var input_direction : int = 0

var jumpPressedRemember : float = 0
onready var wallSlidingBufferTimer = get_node("wallSlidingBuffer")

#state machine constants
const running = "running"
const crouching = "crouching"
const wall_sliding = "wall_sliding"
const ground_sliding = "ground_sliding"

func _process(delta):
	jumpPressedRemember -= delta
	gravity = global.gravity
	maxFallSpeed = global.maxFallSpeed
	speed_change = 8.0
	
	_state_processP()
	if currentState[0] != hitstun:
		_input_process()
	else:
		move(0, 0)
	
#	print(velocity)

func _input_process():
#	if Input.is_action_just_pressed("interact"):
##		print("debug")
#		var debugProjectile = projectile.instance()
#		get_parent().add_child(debugProjectile)
#		debugProjectile.position = position + Vector2(30 * facingDirection, -50)
#		debugProjectile.launch(facingDirection)
	
	input_direction = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	facingDirection = input_direction if input_direction != 0 else facingDirection
	if wallDirection == 0 or wallDirection != 0 and wallDirection != input_direction and groundDirection != -5:
		if currentState[0] != ground_sliding:
			move(input_direction, 0)
		else:
			move(0, 0)
	else:
		move(0, 0)
	
	if Input.is_action_just_pressed("jump"):
		jumpPressedRemember = 0.1
	if jumpPressedRemember > 0:
		jumpPressedRemember = 0
		playback.travel(jumping)
		
		if [idle, walking, running, ground_sliding].has(currentState[0]):
			launch(null, jump_power)
		elif [jumping, wall_sliding].has(currentState[0]) and wallDirection != 0:
			launch(-270 * wallDirection, jump_power)
	
	if Input.is_action_pressed("run") and currentState[0] != crouching:
		max_speed = walk_speed * 1.5
		if input_direction != 0 and Input.is_action_just_pressed("down") and velocity.x != 0 and currentState[0] != jumping:
			playback.travel(ground_sliding)
	elif Input.is_action_just_released("run") or currentState[0] == crouching:
		max_speed = walk_speed
	
	if input_direction != 0 or groundDirection != -5:
		enableWallRaycasts(leftWallRaycasts, true)
		enableWallRaycasts(rightWallRaycasts, true)
	
	if Input.is_action_pressed("down") and Input.is_action_just_pressed("jump") and groundDirection != -5:
		enableCollisionMaskBit(2, false)
		position.y += 2
		yield(get_tree().create_timer(0.5), "timeout")
		enableCollisionMaskBit(2, true)
	
func _state_processP():
#	print(currentState[0] + " | " + currentState[1])
	match currentState[0]:
		idle:
			if Input.is_action_pressed("run") and input_direction != 0:
				playback.travel(running)
				return
			elif Input.is_action_pressed("down"):
				playback.travel(crouching)
				return
			return
		walking:
			if Input.is_action_pressed("run"):
				playback.travel(running)
				return
			elif Input.is_action_pressed("down"):
				playback.travel(crouching)
				return
			return
		running:
			if input_direction == 0 and velocity.x == 0:
				playback.travel(idle)
				return
			if not Input.is_action_pressed("run"):
				if input_direction != 0:
					playback.travel(walking)
					return
			elif groundDirection == -5:
				playback.travel(falling)
				return
			return
		crouching:
			if not Input.is_action_pressed("down") and not detect_roof():
				playback.travel(idle)
				return
			elif groundDirection == -5:
				playback.travel(falling)
				return
		falling:
			if wallDirection != 0 and velocity.y > 10:
				velocity.x = 0
				playback.travel(wall_sliding)
				return
			return
		wall_sliding:
			gravity = global.gravity / 2
			maxFallSpeed = global.maxFallSpeed / 8
			
			if not input_direction == wallDirection and wallSlidingBufferTimer.time_left == 0:
				wallSlidingBufferTimer.start()
			
			if groundDirection != -5:
				playback.travel(idle)
				return
			elif wallDirection == 0 or wallSlidingBufferTimer.time_left < 0.2 and wallSlidingBufferTimer.time_left != 0:
				playback.travel(falling)
				if wallDirection > 0:
					enableWallRaycasts(rightWallRaycasts, false)
				elif wallDirection < 0:
					enableWallRaycasts(leftWallRaycasts, false)
				return
			return
		jumping:
			wallSlidingBufferTimer.stop()
			return
		ground_sliding:
			speed_change = 2.0
			if Input.is_action_just_released("down"):
				if not detect_roof():
					playback.travel(idle)
					return
				elif detect_roof():
					playback.travel(crouching)
					return
				return
			return

func enableWallRaycasts(raycastGroup, enable):
	if enable:
		for raycast in raycastGroup.get_children():
			raycast.enabled = true
	elif not enable:
		for raycast in raycastGroup.get_children():
			raycast.enabled = false

func enableCollisionMaskBit(bit, enable):
	if enable:
		for raycast in groundRaycasts.get_children():
			raycast.set_collision_mask_bit(2, true)
	elif not enable:
		for raycast in groundRaycasts.get_children():
			raycast.set_collision_mask_bit(2, false)

func _on_Hitbox_area_shape_entered(area_id, area, area_shape, self_shape):
	var collider = area.get_parent()
	if collider.get_collision_layer_bit(12) == true:
		if collider.hitbox.get_collision_mask_bit(3) == true:
			print("hitstun")
			hitstun(collider)
	else:
		if groundDirection == -5 and collider.position.y > position.y:
			launch(null, -250)
		else:
			hitstun(collider)
