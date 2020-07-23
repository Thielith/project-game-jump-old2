extends entity
class_name player

var input_direction := 0
var slidingWallTimer := 0.2
export var enableInput := true

#state constants
const running = "running"
const idle_crouch = "idle_crouch"
const walking_crouch = "walking_crouch"
const sliding = "sliding"
const sliding_wall = "sliding_wall"
const jumping_wall = "jumping_wall"

func _process(delta) -> void:
	_state_processP(delta)
#	print(currentState)
	if Input.is_action_just_pressed("interact"):
		print(currentState)

func _physics_process(_delta) -> void:
	_physics_processE(_delta)
	if enableInput:
		input_process()
	else:
		move(0)
	
#	"shorthop" code
#	if velocity.y < 0 and not Input.is_action_pressed("jump"):
#		velocity.y += (gravity * 2) - gravity

func _state_processP(delta) -> void:
	match currentState:
		jumping:
			if wallDirection == input_direction:
				if Input.is_action_just_pressed("jump"):
					wallJump()
					switchState(jumping_wall, false)
					return  #return so it doesnt run _state_process
		falling:
			if wallDirection == input_direction:
				switchState(sliding_wall, false)
				return
			elif velocity.y == 0 and groundDirection != -5 and velocity.x != 0 and Input.is_action_pressed("run"):
				switchState(running, false)
				return
		running:
			if not Input.is_action_pressed("run"):
				switchState(walking, false)
				return
			elif velocity.x == 0:
				switchState(idle, false)
				return
			elif velocity.y > 0 and groundDirection == -5:
				switchState(falling, false)
				return
		idle_crouch:
			if not Input.is_action_pressed("down") and roofDirection == -5:
				switchState(idle, false)
				return
			elif input_direction != 0 and groundDirection != -5:
				switchState(walking_crouch, false)
				return
			elif groundDirection == -5:
				switchState(falling, false)
				return
		walking_crouch:
			speed = int(baseSpeed / 1.5)
			maxSpeed = int(baseMaxSpeed / 1.5)
			if not Input.is_action_pressed("down") and roofDirection == -5:
				if Input.is_action_pressed("run"):
					switchState(running, false)
					return
				else:
					switchState(walking, false)
					return
			elif velocity.x == 0 and groundDirection != -5 and input_direction == 0:
				switchState(idle_crouch, false)
				return
			elif groundDirection == -5:
				switchState(falling, false)
				return
		sliding:
			if not Input.is_action_pressed("down"):
				if input_direction == 0:
					if roofDirection == -5:
						switchState(idle, false)
					else:
						switchState(idle_crouch, false)
				else:
					if Input.is_action_pressed("run"):
						if roofDirection != -5:
							switchState(walking_crouch, false)
						else:
							switchState(running, false)
					else:
						if roofDirection == -5:
							switchState(walking, false)
						else:
							switchState(walking_crouch, false)
				friction = baseFriction
				return
		sliding_wall:
			if velocity.y > 0:
				velocity.y = 30
				velocity.x = 0
			if not [wallDirection, 0].has(input_direction):
				slidingWallTimer -= delta
				if Input.is_action_just_pressed("jump"):
					slidingWallTimer = 0.2
					wallJump()
					switchState(jumping_wall, false)
					return
				elif slidingWallTimer < 0:
					slidingWallTimer = 0.2
					switchState(falling, false)
					return
			elif Input.is_action_just_pressed("jump"):
				wallJump()
				switchState(jumping_wall, false)
				return
			elif groundDirection != -5:
				switchState(idle, false)
				return
		jumping_wall:
			if velocity.y > 0:
				switchState(falling, false)
				return
			elif wallDirection == input_direction:
				if Input.is_action_just_pressed("jump"):
					velocity.y = jumpHeight
					position.x += 5 * -wallDirection
					velocity.x = 300 * -wallDirection
					wallDirection = -5
				else:
					switchState(sliding_wall, false)
				return
		hitstun:
			friction = baseFriction
			speed = baseSpeed
			maxSpeed = baseMaxSpeed
	_state_process()

func wallJump() -> void:
	velocity.y = jumpHeight
	position.x += 5 * pow(-1, (1*int(wallDirection < 0)))
	velocity.x = 300 * -pow(-1, (1*int(wallDirection < 0)))
	wallDirection = -5

func input_process() -> void:
	input_direction = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	
	if Input.is_action_pressed("run") and input_direction != 0 and velocity.x != 0 and not [idle_crouch, walking_crouch, sliding].has(currentState):
		speed = baseSpeed * 2
		maxSpeed = baseMaxSpeed * 2
		if groundDirection != -5:
			switchState(idle, true)
			switchState(running, false)
	
	if Input.is_action_just_pressed("jump") and groundDirection != -5 and not [idle_crouch, walking_crouch, sliding, sliding_wall].has(currentState):
		groundDirection = -5
		velocity.y = jumpHeight
		switchState(jumping, false)
	
	if Input.is_action_pressed("down"):
		if Input.is_action_just_pressed("jump") and groundDirection != -5:
			position.y += 2
		if [walking_crouch, idle].has(currentState) and input_direction == 0:
			switchState(idle_crouch, false)
		elif [walking, idle_crouch, idle].has(currentState) and input_direction != 0:
			switchState(walking_crouch, false)
		elif [running, sliding].has(currentState):
			friction = baseFriction / 3
			switchState(sliding, false)
	
	if [idle_crouch, walking_crouch, sliding].has(currentState):
		changeRaycasts(true, -59.2, -57.0, 17.0 if currentState == sliding else 10)
		changeCollisionShape(29.5, 17.0 if currentState == sliding else 10)
	else:
		changeRaycasts()
		changeCollisionShape()
	
	if not [running, jumping, falling, walking_crouch, sliding_wall, jumping_wall].has(currentState):
		speed = baseSpeed
		maxSpeed = baseMaxSpeed
	
	if [sliding].has(currentState):
		move(0)
	else:
		move(input_direction)
	
#	if wallDirection != -5 and wallDirection * velocity.x > 0 and groundDirection != -5 and input_direction == -wallDirection:
#		velocity.x = -velocity.x
#		print("hello")

func changeRaycasts(extendRoof:= false, top:= -72.7, head:= -67.0, sides:= 10.0, feet:= -5.0, bottom:= -0.2):
	$raycasts/groundRaycastL.position = Vector2(-sides, bottom)
	$raycasts/groundRaycastR.position = Vector2(sides, bottom)
	$raycasts/wallL/raycastT.position = Vector2(-sides, head)
	$raycasts/wallL/raycastB.position = Vector2(-sides, feet)
	$raycasts/wallR/raycastT.position = Vector2(sides, head)
	$raycasts/wallR/raycastB.position = Vector2(sides, feet)
	$raycasts/roofRaycastL.position = Vector2(-sides, top)
	$raycasts/roofRaycastR.position = Vector2(sides, top)
	if extendRoof:
		$raycasts/roofRaycastL.cast_to.y = -10
		$raycasts/roofRaycastR.cast_to.y = -10
	else:
		$raycasts/roofRaycastL.cast_to.y = -3
		$raycasts/roofRaycastR.cast_to.y = -3
func changeCollisionShape(limitY:= 36.5, limitX:= 10.0):
	$CollisionShape2D.shape.extents.x = limitX
	$CollisionShape2D.shape.extents.y = limitY
	$CollisionShape2D.position.y = -limitY
	$hitbox/hitbox.shape.extents.x = limitX + 0.5
	$hitbox/hitbox.shape.extents.y = limitY + 0.5
	$hitbox/hitbox.position.y = -limitY - 0.5

func loadBattle():
	get_parent().get_parent().loadBattle()

func _on_hitbox_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.get_parent().loadsBattle:
		loadBattle()
	else:
		if not [idle_crouch, walking_crouch, sliding].has(currentState):
			switchState(hitstun, true)
			position.y -= 2
			if area.get_parent().position.x > position.x:
				setVelocity(-200, -100)
			else:
				setVelocity(200, -100)

func _on_attackHitbox_area_shape_entered(_area_id, area, _area_shape, _self_shape):
	if area.get_parent().loadsBattle:
		loadBattle()
	else:
		velocity.y = jumpHeight
		position.y -= 5
		switchState(jumping, false)
