extends KinematicBody2D
class_name entity_o

onready var global = get_node("/root/global_var")
onready var groundRaycasts = get_node("groundRaycasts")
onready var roofRaycasts = get_node("roofRaycasts")
onready var animationPlayer = get_node("AnimationTree/AnimationPlayer")
onready var stateMachine = get_node("stateMachine")
onready var playback = stateMachine.get("parameters/playback")
var currentState = ["none", "none"]

export var walk_speed : float = 100.0
var max_speed : float = walk_speed
export var speed_change : float = 8.0
export var jump_power : int = 0

var FLOOR : Vector2 = Vector2.UP
var snapToFloor : bool = true
onready var gravity = global.gravity
onready var maxFallSpeed : int = global.maxFallSpeed
var snap : Vector2 = Vector2(0, 32)
var groundDirection : int = 0

onready var leftWallRaycasts = get_node("wallRaycasts/leftWallRaycasts")
onready var rightWallRaycasts = get_node("wallRaycasts/rightWallRaycasts")
var wallDirection : int = 0

var facingDirection : int = -1

onready var hitstunTimer = get_node("hitstunTimer")

var velocity : Vector2 = Vector2()

var pauseGame : bool = false

#state machine constants
const idle = "idle"
const walking = "walking"
const jumping = "jumping"
const falling = "falling"
const hitstun = "hitstun"

func _ready():
	playback.start(idle)
	stateMachine.active = true

func _process(delta):
	if not pauseGame:
		_state_process()

func _physics_process(delta):
	if not pauseGame:
		gravity()
		detect_ground()
		detect_wall()
	#	print(velocity)
		
		FLOOR = Vector2.UP if snapToFloor else Vector2(0, 1)
		
		move_and_slide_with_snap(velocity, snap, FLOOR, true, 4, 0.802851)

func _state_process():
	if currentState[0] != playback.get_current_node():
		currentState.push_front(playback.get_current_node())
		currentState.pop_back()
	match currentState[0]:
		idle:
			if velocity.x != 0:
				playback.travel(walking)
				return
			elif groundDirection == -5:
				playback.travel(falling)
				return
			return
		walking:
			if velocity.x == 0:
				playback.travel(idle)
				return
			elif groundDirection == -5:
				playback.travel(falling)
				return
			return
		jumping:
			snapToFloor = false
			if velocity.y > 0.5:
				playback.travel(falling)
				return
			elif velocity.y == 0 and groundDirection != -5:
				playback.travel(idle)
				return
			return
		falling:
			snapToFloor = true
			if groundDirection != -5:
				playback.travel(idle)
				return
			elif velocity.y < 0.01:
				playback.travel(jumping)
				return
			return
		hitstun:
			if hitstunTimer.time_left == 0:
				hitstunTimer.start()
			yield(hitstunTimer, "timeout")
			playback.travel(idle)
			return

func gravity():
	if groundDirection == -5:
		if velocity.y < maxFallSpeed:
			velocity.y += gravity
		elif velocity.y > maxFallSpeed:
			velocity.y -= gravity
		
		if detect_roof() and velocity.y < 0:
			if int(-velocity.y / 2) > 50:
				velocity.y = 50
			else:
				velocity.y = int(-velocity.y / 2)
	elif velocity.y > 0.01:
		velocity.y = 0

func detect_ground():
	var raycasts = groundRaycasts.get_children()
	if not [raycasts[0].is_colliding(), raycasts[1].is_colliding()].has(true):
		groundDirection = -5
	else:
		groundDirection = int(raycasts[1].is_colliding()) - int(raycasts[0].is_colliding())
func detect_roof():
	for raycast in roofRaycasts.get_children():
		if raycast.is_colliding():
			return true
	return false
func detect_wall():
	var wallLeft : bool = false
	var wallRight : bool = false
	
	for raycast in leftWallRaycasts.get_children():
		if raycast.is_colliding():
			wallLeft = true
	for raycast in rightWallRaycasts.get_children():
		if raycast.is_colliding():
			wallRight = true
	
	wallDirection = int(wallRight) - int(wallLeft)

func move(direction, movement_multiplier):
	if direction != 0:
		if velocity.x < max_speed * direction:
			velocity.x += (speed_change + movement_multiplier)
		elif velocity.x > max_speed * direction:
			velocity.x -= (speed_change + movement_multiplier)
	else:
		if velocity.x > 0:
			velocity.x -= speed_change
			if velocity.x < 0:
				velocity.x = 0
		elif velocity.x < 0:
			velocity.x += speed_change
			if velocity.x > 0:
				velocity.x = 0

func launch(power_x, power_y):
	snapToFloor = false
	if power_x != null:
		velocity.x = power_x
	if power_y != null:
		velocity.y = power_y

func hitstun(collider):
	playAnimation(hitstun)
	playback.travel(hitstun)
	if position.x < collider.position.x:
		launch(-100, 20)
	else:
		launch(100, 20)


func playAnimation(animation):
	animationPlayer.play(animation)	
