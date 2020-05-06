extends entity
class_name enemy

onready var patrol_origin : Vector2 = get_global_position()
var patrolDistance : int = 100
var patrolDirection : int = 1
onready var patrolStopTimer = get_node("patrolStopTimer")

onready var player = get_parent().get_parent().get_node("player")
var playerDirection : int
export var chase_speed : float
export var pixel_width : int
var eye_reach = 25 + pixel_width/2
var vision = 32 * 10

var chasing : bool = false
var playingTimedAnimation : bool = false

#state machine constants
const alert = "alert"
const chase = "chase"
const attacking = "attacking"

func _ready():
	pauseGame = true

func _physics_process(delta):
	if not pauseGame:
		if not playingTimedAnimation and groundDirection != -5:
			if not [alert, chase].has(currentState[0]):
				if patrolStopTimer.time_left < 0.1:
					patrol(patrolDirection)
				else:
					patrol(0)
			elif currentState[0] == alert:
				patrol(0)
		else:
			move(0, 0)
		pass

func _process(delta):
	if not pauseGame:
		_state_processE()
		if velocity.x > 0:
			facingDirection = 1
		elif velocity.x < 0:
			facingDirection = -1
		
		if player.position.x > position.x:
			playerDirection = 1
		elif player.position.x < position.x:
			playerDirection = -1
		else:
			playerDirection = 0

func _on_patrolStopTimer_timeout():
	pass

func _state_processE():
#	print(currentState[0] + " | " + currentState[1])
	match currentState[0]:
		idle, walking:
			if chasing:
				playback.travel(chase)
			elif sees_player():
				playback.travel(alert)
				return
			return
		alert:
			yield(get_tree().create_timer(1.0), "timeout")
			if sees_player():
				chasing = true
				playback.travel(chase)
				return
			else:
				playback.travel(idle)
				return
			return
		chase:
			if not sees_player():
				chasing = false
				playback.travel(idle)
				return
			return
		attacking:
			snapToFloor = false
			if velocity.y > 0.5:
				playback.travel(falling)
				return
			elif velocity.y == 0 and groundDirection != -5:
				playback.travel(idle)
				return
			return

func patrol(move_direction):
	move(move_direction, 0)
	if patrolStopTimer.is_stopped():
		if position.x > patrol_origin.x + patrolDistance or wallDirection == 1:
			if patrolDirection != -1:
				patrolStopTimer.start()
				patrolDirection = -1
		elif position.x < patrol_origin.x - patrolDistance or wallDirection == -1:
			if patrolDirection != 1:
				patrolStopTimer.start()
				patrolDirection = 1
func chase():
	max_speed = chase_speed
	if player.position.x > position.x:
		move(1, 0)
	elif player.position.x < position.x:
		move(-1, 0)
func sees_player():
	var eye_center = get_global_position()
	var eye_top = eye_center + Vector2(0, -eye_reach)
	var eye_left = eye_center + Vector2(-eye_reach, 0)
	var eye_right = eye_center + Vector2(eye_reach, 0)
	
	var player_pos = player.get_global_position()
	var player_extents = player.get_node("CollisionShape2D").shape.extents - Vector2(1, 1)
	var top_left = player_pos + Vector2(-player_extents.x, -player_extents.y)
	var top_right = player_pos + Vector2(player_extents.x, -player_extents.y)
	var bottom_left = player_pos + Vector2(-player_extents.x, player_extents.y)
	var bottom_right = player_pos + Vector2(player_extents.x, player_extents.y)
	
	var space_state = get_world_2d().direct_space_state

	for eye in [eye_center, eye_top, eye_left, eye_right]:
		for corner in [top_left, top_right, bottom_left, bottom_right]:
			if (corner - eye).length() > vision:
				continue
			var collision = space_state.intersect_ray(eye, corner, [], 3) # collision mask = sum of 2^(collision layers) - e.g 2^0 + 2^3 = 9
			if collision and collision.collider.name == "player":
				return true
	return false

func jump(horizontal):
	snapToFloor = false
	playback.travel(jumping)
	launch(horizontal, jump_power - 100)

func loadBattle():
	get_parent().get_parent().loadBattle()
