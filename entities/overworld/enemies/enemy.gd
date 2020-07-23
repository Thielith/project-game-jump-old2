extends entity
class_name enemy

export var isPatroling : bool = true
var patrolDirection := 0
export var attackRange : Vector2
export var idleTime := 1.0
export var spawnsProjectile := false
export var projectileSpawned := false
export var projectileSprite : Texture
export var projectileVelocity := Vector2.ZERO
export var loadsBattle := true

onready var player = get_parent().get_parent().get_node("player")
var playerDirection : int = 0
export var pixel_width : int
var eye_reach = 25 + pixel_width/2.0
var vision = 32 * 10

#state constants
const attacking = "attacking"
const hit = "hit"
const die = "die"
const chase = "chase"

func _ready() -> void:
	patrolDirection = randi()%2-1
	if patrolDirection == 0:
		_ready()
		return

func _physics_process(_delta) -> void:
	_physics_processE(_delta)

func _process(_delta) -> void:
	_state_processE()
	playerDirection = int(position < player.position) - int(position > player.position)
	if isPatroling:
		maxSpeed = baseMaxSpeed
		patrol()

func _state_processE() -> void:
	match currentState:
		idle:
			if groundDirection != -5 and not isPatroling:
				velocity.x = 0
			if not $idleTimer.is_stopped():
				yield($idleTimer, "timeout")
				$walkingTimer.start()
				isPatroling = true
		falling:
			if groundDirection != -5:
				velocity.x = 0
		chase:
			chasePlayer()
			maxSpeed = 100
			if abs(player.position.x - position.x) < attackRange.x and abs(player.position.y - position.y) < attackRange.y:
				velocity.x = 0
				$walkingTimer.stop()
				switchState(attacking, false)
				return
			elif abs(player.position.x - position.x) < 16 and player.position.y - position.y < -44:
				velocity.x = 0
				velocity.y = -20
				$walkingTimer.stop()
				switchState(jumping, false)
				return
			elif not sees_player():
				$walkingTimer.stop()
				velocity.x = 0
				switchState(idle, false)
				yield(get_tree().create_timer(idleTime), "timeout")
				maxSpeed = baseMaxSpeed
				isPatroling = true
				return
		attacking:
			if groundDirection != -5 and velocity.x != 0 or spawnsProjectile and projectileSpawned:
				projectileSpawned = false
				switchState(idle, false)
				yield(get_tree().create_timer(0.2), "timeout")
				isPatroling = true
				return
		hit:
			if groundDirection != -5:
				velocity.x = 0
		hitstun:
			velocity = Vector2(0, -jumpHeight)
		die:
			pass
	_state_process()

func patrol() -> void:
	if [abs(groundDirection), abs(wallDirection)].has(1) or $walkingTimer.is_stopped():
		$walkingTimer.stop()
		isPatroling = false
		velocity.x = 0
		position.x -= 1 * patrolDirection
		yield(get_tree().create_timer(idleTime), "timeout")
		patrolDirection = -patrolDirection
		isPatroling = true
		$walkingTimer.start()
	elif groundDirection != -5:
		move(patrolDirection)
	
	if sees_player():
		isPatroling = false
		switchState(chase, false)

func sees_player() -> bool:
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

func chasePlayer() -> void:
	move(playerDirection)

func spawnProjectile(projectile):
	var p = projectile.instance()
	p.get_node("Sprite").texture = projectileSprite
	p.hasGravity = true
	p.loadsBattle = true
	p.velocity = projectileVelocity
	get_parent().add_child(p)
	p.position = $projectileSpawn.get_global_position()
