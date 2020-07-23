extends KinematicBody2D
class_name entity_rpg

export var velocity : Vector2 = Vector2()
onready var appliedGravity = global_var.gravity
var enableGravity : bool = false
onready var groundRaycast = get_node("groundRaycast")
onready var hitbox = get_node("Hitbox")
onready var hitboxAttack = get_node("AttackHitbox")
export var spriteHeight : float
var combatLayer : int

var origin : Vector2
var newLocation : Vector2 = origin
var travelTime : float = 1.0

onready var animationPlayer = get_node("AnimationPlayer")
onready var currentAnimation = [animationPlayer.get("current_animation"), "none"]
export var portrait : Texture
var actionToPerform
var newCombatLayer : int
var targetLocation : Vector2
var returning : bool = false
var turnEnded : bool = false
export var projectileImage : Texture
var target

export var attacks : Array = []

func _physics_process(_delta) -> void:
	if enableGravity:
		gravity()
		if animationPlayer.assigned_animation.ends_with("r") and groundRaycast.is_colliding():
			velocity.x -= abs(velocity.x / 10) * (-1*int(velocity.x < 0))
			if velocity.x * (-1*int(velocity.x < 0)) <= 5:
				velocity.x = 0
				animationPlayer.stop()
				animationPlayer.play("return")
	var _unused = move_and_slide(velocity)

func gravity() -> void:
	if not groundRaycast.is_colliding():
		velocity.y += appliedGravity
	elif velocity.y > 0.01:
		velocity.y = 0

func performAction() -> void:
	if not returning:
		print(actionToPerform.function + "_" + actionToPerform.id)
		setCombatLayer(newCombatLayer)
		enableGravity = true
		animationPlayer.stop()
		animationPlayer.play(actionToPerform.function + "_" + actionToPerform.id)
		
	else:
		animationPlayer.play("idle")
		endTurn()

func moveToLocation() -> void:
	animationPlayer.get_animation("moveToLocation").track_set_key_value(0, 0, position)
	animationPlayer.get_animation("moveToLocation").track_set_key_value(0, 1, newLocation)
	animationPlayer.stop()
	animationPlayer.play("moveToLocation")

func setCombatLayer(layer) -> void:
	groundRaycast.set_collision_mask_bit(5, false)
	groundRaycast.set_collision_mask_bit(6, false)
	groundRaycast.set_collision_mask_bit(7, false)
	groundRaycast.set_collision_mask_bit(8, false)
	groundRaycast.set_collision_mask_bit(9, false)
	
	set_collision_mask_bit(5, false)
	set_collision_mask_bit(6, false)
	set_collision_mask_bit(7, false)
	set_collision_mask_bit(8, false)
	set_collision_mask_bit(9, false)
	
	if layer != null:
		groundRaycast.set_collision_mask_bit(4 + layer, true)
		set_collision_mask_bit(4 + layer, true)
func setCombatState(reading : bool, readable : bool, physical : bool) -> void:
	hitbox.monitoring = reading
	hitbox.monitorable = reading
	hitboxAttack.monitoring = readable
	hitboxAttack.monitorable = readable
	get_node("CollisionShape2D").disabled = !physical

func setVelocity(change_x : float, change_y : float) -> void:
	if not typeof(change_x) == TYPE_BOOL:
		velocity.x = change_x
	if not typeof(change_y) == TYPE_BOOL:
		velocity.y = change_y
func setMoveVelocity(targetPos : Vector2, arc : bool) -> Vector2:
	var changeX = (targetPos.x - position.x)
	var changeY = (targetPos.y - position.y)
	var slope = sqrt(changeX*changeX + changeY*changeY)
	var newVelocity = slope / travelTime
	
	var angle = get_angle_to(targetPos)
	var newVelocityY = newVelocity * sin(angle)
	var newVelocityX = newVelocity * cos(angle)

	if arc:
		newVelocityY = -77 * (log(abs(newVelocityX)/3) / log(2.71828))
#	print("Change X: " + str(changeX))
#	print("Change Y: " + str(changeY))
#	print("Slope: " + str(slope))
#	print("New Velocity: " + str(newVelocity))
#	print("Angle: " + str(angle))
#	print("New Velocity X: " + str(newVelocityX))
#	print("New Velocity Y: " + str(newVelocityY))
	return Vector2(newVelocityX, newVelocityY)

func returnToOrigin() -> void:
	enableGravity = false
	setCombatLayer(combatLayer)
	
	newLocation = origin
	returning = true
	get_node("../../").currentChoiceState = 0
	get_node("../../").uiAnimationPlayer.play("show")
	setCombatState(false, false, false)
	target.setCombatState(false, false, false)
	moveToLocation()

func endTurn() -> void:
	returning = false
	turnEnded = true
	setCombatState(false, false, false)
	target.setCombatState(false, false, false)
	get_node("../../").processingAttack = false
	get_node("../../").checkPartyStatus()

func playAnimation(anim : String) -> void:
	animationPlayer.play(anim)

func jump() -> void:
	var calc : Vector2 = setMoveVelocity(targetLocation, true)
	setVelocity(calc.x , calc.y)
	
func launch() -> void:
	var calc : Vector2 = setMoveVelocity(targetLocation * 0.25, false)
	setVelocity(calc.x, calc.y)
func throwProjectile() -> void:
	var activeProjectile = load("res://entities/projectiles/projectile_rpg.tscn").instance()
	add_child(activeProjectile)
	activeProjectile.position = $projSpawn.position
	activeProjectile.get_node("Sprite").texture = projectileImage
	
	var calc : Vector2 = setMoveVelocity(targetLocation * 0.25, false)
	activeProjectile.velocity = calc
