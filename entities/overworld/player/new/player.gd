extends KinematicBody2D
class_name player_n

var input_direction := 0

var velocity := Vector2()
var gravity = global_var.gravity
var groundDirection := 0
var wallDirection := 0
var roofDirection := 0
onready var playbackAnim = $AnimationTree.get("parameters/playback")
onready var currentState = idle

var slidingWallTimer := 0.2

export var baseSpeed : float = 0.0
export var baseMaxSpeed : float = 0.0
export var baseFriction : float = 0.0
export var baseJumpHeight : float = 0.0
export var enableGravity : bool = true

onready var speed = baseSpeed
onready var maxSpeed = baseMaxSpeed
onready var friction = baseFriction
onready var jumpHeight = baseJumpHeight

#state constants
const idle = "idle"
const walking = "walking"
const running = "running"
const jumping = "jumping"
const falling = "falling"
const idle_crouch = "idle_crouch"
const walking_crouch = "walking_crouch"
const sliding = "sliding"
const sliding_wall = "sliding_wall"
const jumping_wall = "jumping_wall"

func _ready():
	playbackAnim.start("idle")
	$AnimationTree.active = true
	yield(get_tree().create_timer(0.1), "timeout")

func _process(delta):
	_state_processP(delta)
	if Input.is_action_just_pressed("interact"):
		print(velocity)

func _physics_process(_delta):
	print(velocity)
	raycastDetection()
	input_process()
	
	if enableGravity:
		if groundDirection == -5:
			velocity.y += gravity
		else:
			velocity.y = 0
	
	if velocity.y > 0:
		velocity.y += (gravity * 1.5) - gravity
#	elif velocity.y < 0 and not Input.is_action_pressed("jump"):
#		velocity.y += (gravity * 2) - gravity
	
	move_and_slide(velocity)

func switchState(newState):
	if newState != currentState:
		print(newState)
		currentState = newState
		playbackAnim.travel(newState)

func _state_process():
	match currentState:
		idle:
			if velocity.x != 0 and groundDirection != -5:
				switchState(walking)
			elif velocity.y > 0 and groundDirection == -5:
				switchState(falling)
		walking:
			if velocity.x == 0 and groundDirection != -5:
				switchState(idle)
			elif velocity.y > 0 and groundDirection == -5:
				switchState(falling)
		jumping:
			if velocity.y == 0 and groundDirection != -5:
				switchState(idle)
			if velocity.y > 0.01:
				switchState(falling)
		falling:
			if velocity.y == 0 and groundDirection != -5:
				if velocity.x != 0:
					switchState(walking)
				else:
					switchState(idle)
			elif velocity.y < 0:
				switchState(jumping)

func _state_processP(delta):
	match currentState:
		jumping:
			if wallDirection == input_direction:
				if Input.is_action_just_pressed("jump"):
					switchState(jumping_wall)
				else:
					switchState(sliding_wall)
				return
		falling:
			if wallDirection == input_direction:
				switchState(sliding_wall)
				return
			elif velocity.y == 0 and groundDirection != -5 and velocity.x != 0 and Input.is_action_pressed("run"):
				switchState(running)
				return
		running:
			if not Input.is_action_pressed("run"):
				switchState(walking)
				return
			elif velocity.x == 0:
				switchState(idle)
				return
			elif velocity.y > 0 and groundDirection == -5:
				switchState(falling)
				return
		idle_crouch:
			if not Input.is_action_pressed("down") and roofDirection == -5:
				switchState(idle)
				return
			elif input_direction != 0 and groundDirection != -5:
				switchState(walking_crouch)
				return
			elif groundDirection == -5:
				switchState(falling)
				return
		walking_crouch:
			speed = int(baseSpeed / 1.5)
			maxSpeed = int(baseMaxSpeed / 1.5)
			if not Input.is_action_pressed("down") and roofDirection == -5:
				switchState(walking)
				return
			elif velocity.x == 0 and groundDirection != -5 and input_direction == 0:
				switchState(idle_crouch)
				return
			elif groundDirection == -5:
				switchState(falling)
				return
		sliding:
			if not Input.is_action_pressed("down"):
				if Input.is_action_pressed("run"):
					if roofDirection != -5:
						switchState(walking_crouch)
					else:
						switchState(running)
				elif input_direction != 0:
					if roofDirection == -5:
						switchState(walking)
					else:
						switchState(walking_crouch)
				else:
					if roofDirection == -5:
						switchState(idle)
					else:
						switchState(idle_crouch)
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
					velocity.y = jumpHeight
					position.x += 5 * pow(-1, (1*int(wallDirection < 0)))
					velocity.x = 300 * -pow(-1, (1*int(wallDirection < 0)))
					wallDirection = -5
					switchState(jumping_wall)
					return
				elif slidingWallTimer < 0:
					slidingWallTimer = 0.2
					switchState(falling)
					return
			elif Input.is_action_just_pressed("jump"):
				velocity.y = jumpHeight
				position.x += 5 * pow(-1, (1*int(wallDirection < 0)))
				velocity.x = 300 * -pow(-1, (1*int(wallDirection < 0)))
				wallDirection = -5
				switchState(jumping_wall)
				return
			elif groundDirection != -5:
				switchState(idle)
				return
		jumping_wall:
			if velocity.y > 0:
				switchState(falling)
				return
			elif wallDirection == input_direction:
				if Input.is_action_just_pressed("jump"):
					velocity.y = jumpHeight
					position.x += 5 * -wallDirection
					velocity.x = 300 * -wallDirection
					wallDirection = -5
				else:
					switchState(sliding_wall)
				return
	_state_process()

func input_process():
	input_direction = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	
	if Input.is_action_pressed("run") and input_direction != 0 and velocity.x != 0 and not [idle_crouch, walking_crouch, sliding].has(currentState):
		speed = baseSpeed * 2
		maxSpeed = baseMaxSpeed * 2
		if groundDirection != -5:
			switchState(running)
	
	if Input.is_action_just_pressed("jump") and groundDirection != -5 and not [idle_crouch, walking_crouch, sliding, sliding_wall].has(currentState):
		groundDirection = -5
		velocity.y = jumpHeight
		switchState(jumping)
	
	if Input.is_action_pressed("down"):
		if [walking_crouch, idle].has(currentState) and input_direction == 0:
			switchState(idle_crouch)
		elif [walking, idle_crouch, idle].has(currentState) and input_direction != 0:
			switchState(walking_crouch)
		elif [running, sliding].has(currentState):
			input_direction = 0
			friction = baseFriction / 3
			switchState(sliding)
	
	if not [running, jumping, falling, walking_crouch, sliding_wall, jumping_wall].has(currentState):
		speed = baseSpeed
		maxSpeed = baseMaxSpeed
	
	if abs(velocity.x) < maxSpeed and input_direction != 0 and wallDirection != input_direction:
		if abs(velocity.x + (speed * input_direction)) < maxSpeed:
			velocity.x += speed * input_direction
	else:
		if abs(velocity.x) > 0:
			velocity.x -= friction * pow(-1, int(velocity.x < 0))
			if abs(velocity.x) < friction + 1 or input_direction == wallDirection:
				velocity.x = 0
	
#	if wallDirection != -5 and wallDirection * velocity.x > 0 and groundDirection != -5 and input_direction == -wallDirection:
#		velocity.x = -velocity.x
#		print("hello")

func raycastDetection():
	var groundL = $raycasts/groundRaycastL
	var groundR = $raycasts/groundRaycastR
	groundDirection = int(groundR.is_colliding()) - int(groundL.is_colliding())
	if not groundL.is_colliding() and not groundR.is_colliding():
		groundDirection = -5
	
	var wallL = [$raycasts/wallL/raycastT, $raycasts/wallL/raycastB]
	var wallR = [$raycasts/wallR/raycastT, $raycasts/wallR/raycastB]
	wallDirection = int(wallR[0].is_colliding() or wallR[1].is_colliding()) - int(wallL[0].is_colliding() or wallL[1].is_colliding())
	if not (wallL[0].is_colliding() or wallL[1].is_colliding()) and not (wallR[0].is_colliding() or wallR[1].is_colliding()):
		wallDirection = -5   #im not screenshoting the whole thing
	
	var roofL = $raycasts/roofRaycastL
	var roofR = $raycasts/roofRaycastR
	roofDirection = int(roofR.is_colliding()) - int(roofL.is_colliding())
	if not roofL.is_colliding() and not roofR.is_colliding():
		roofDirection = -5
