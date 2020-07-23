extends KinematicBody2D
class_name entity

var velocity := Vector2()
var gravity = global_var.gravity
var groundDirection := 0
var wallDirection := 0
var roofDirection := 0
onready var playbackAnim = $AnimationTree.get("parameters/StateMachine/playback")
onready var currentState : String = idle

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
const jumping = "jumping"
const falling = "falling"
const hitstun = "hitstun"

func _ready() -> void:
	playbackAnim.start("idle")
	$AnimationTree.active = true
	yield(get_tree().create_timer(0.1), "timeout")
	
func _physics_processE(_delta) -> void:
	raycastDetection()
	
#	$AnimationTree/AnimationPlayer.set_speed_scale(abs(velocity.x / maxSpeed))
#	print($AnimationTree/AnimationPlayer.playback_speed)
	
	if enableGravity:
		if groundDirection == -5:
			velocity.y += gravity
		else:
			velocity.y = 0
	if velocity.y > 0:
		velocity.y += (gravity * 1.5) - gravity
	
	var _unused = move_and_slide(velocity)

func switchState(newState : String, hardSet : bool) -> void:
	if newState != currentState:
#		print(str(name) + ": " + newState)
		currentState = newState
		if hardSet:
			setAnim(newState)
		else:
			playbackAnim.travel(newState)
func setAnim(newAnim : String):
	playbackAnim.stop()
	playbackAnim.start(newAnim)

func _state_process() -> void:
	match currentState:
		idle:
			$raycasts/groundRaycastL.enabled = true
			$raycasts/groundRaycastR.enabled = true
			if abs(velocity.x) > 0 and groundDirection != -5:
				switchState(walking, false)
			elif velocity.y > 0 and groundDirection == -5:
				switchState(falling, false)
		walking:
			if velocity.x == 0 and groundDirection != -5:
				switchState(idle, false)
			elif velocity.y > 0 and groundDirection == -5:
				switchState(falling, false)
		jumping:
			$raycasts/groundRaycastL.enabled = false
			$raycasts/groundRaycastR.enabled = false
			if velocity.y == 0 and groundDirection != -5:
				switchState(idle, false)
			elif velocity.y > 0.01 or roofDirection != -5:
				if roofDirection != -5:
					position.y += 2
					velocity.y = -velocity.y
				switchState(falling, false)
		falling:
			$raycasts/groundRaycastL.enabled = true
			$raycasts/groundRaycastR.enabled = true
			if velocity.y == 0 and groundDirection != -5:
				if velocity.x != 0:
					switchState(walking, false)
				else:
					switchState(idle, false)

func raycastDetection() -> void:
	var groundL = $raycasts/groundRaycastL
	var groundR = $raycasts/groundRaycastR
	groundDirection = int(groundL.is_colliding()) - int(groundR.is_colliding())
	if not groundL.is_colliding() and not groundR.is_colliding():
		groundDirection = -5
	
	var wallL = [$raycasts/wallL/raycastT, $raycasts/wallL/raycastB]
	var wallR = [$raycasts/wallR/raycastT, $raycasts/wallR/raycastB]
	wallDirection = int(wallR[0].is_colliding() or wallR[1].is_colliding()) - int(wallL[0].is_colliding() or wallL[1].is_colliding())
	if not (wallL[0].is_colliding() or wallL[1].is_colliding()) and not (wallR[0].is_colliding() or wallR[1].is_colliding()):
		wallDirection = -5
	
	var roofL = $raycasts/roofRaycastL
	var roofR = $raycasts/roofRaycastR
	roofDirection = int(roofL.is_colliding()) - int(roofR.is_colliding())
	if not roofL.is_colliding() and not roofR.is_colliding():
		roofDirection = -5

func move(direction):
	if abs(velocity.x) < maxSpeed and direction != 0 and wallDirection != direction:
		if abs(velocity.x + (speed * direction)) < maxSpeed:
			velocity.x += speed * direction
	else:
		if abs(velocity.x) > 0:
			velocity.x -= friction * pow(-1, int(velocity.x < 0))
			if abs(velocity.x) < friction + 1 or direction == wallDirection:
				velocity.x = 0

func setVelocity(Vx, Vy) -> void:
	if [TYPE_REAL, TYPE_INT].has(typeof(Vx)):
		velocity.x = Vx
	if [TYPE_REAL, TYPE_INT].has(typeof(Vy)):
		velocity.y = Vy

func jump():
	groundDirection = -5
	position.y -= 3
	setVelocity(0, jumpHeight)
