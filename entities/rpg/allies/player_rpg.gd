extends KinematicBody2D

export var velocity : Vector2 = Vector2()
export var spriteHeight : float
export var attacks : Array = [[], []]

var gravity := false
var origin : Vector2
var originCombatLayer : int

var currentAttack : Dictionary
var canCombo := false
var comboTimer : float
var comboLimit : int = 1

var returning := false
var completedTurn := false

func _physics_process(delta):
	if gravity:
		velocity.y += global_var.gravity
		var _unused = move_and_slide(velocity)
		if $groundRaycast.is_colliding() and returning:
			returnToOrigin()
	
	if canCombo:
		if Input.is_action_just_pressed("jump"):
			comboTimer = 0.2
			canCombo = false
	if comboTimer > 0:
		comboTimer -= delta	

func jumpToPosition(newPosition):
	var changeX = (newPosition.x - position.x)
	var changeY = (newPosition.y - position.y)
	var slope = sqrt(changeX*changeX + changeY*changeY)
	var newVelocity = slope / 1
	
	var angle = get_angle_to(newPosition)
	var newVelocityY = newVelocity * sin(angle)
	var newVelocityX = newVelocity * cos(angle)

	newVelocityY = -100 * (log(abs(newVelocityX)/3) / log(2.71828))
	
	gravity = true
	velocity = Vector2(newVelocityX, newVelocityY)

func setCombatLayer(bit : int) -> void:
	$groundRaycast.set_collision_mask_bit(5, false)
	$groundRaycast.set_collision_mask_bit(6, false)
	$groundRaycast.set_collision_mask_bit(7, false)
	$groundRaycast.set_collision_mask_bit(8, false)
	$groundRaycast.set_collision_mask_bit(9, false)
	$groundRaycast.set_collision_mask_bit(bit + 4, true)
	
	set_collision_mask_bit(5, false)
	set_collision_mask_bit(6, false)
	set_collision_mask_bit(7, false)
	set_collision_mask_bit(8, false)
	set_collision_mask_bit(9, false)
	set_collision_mask_bit(bit + 4, true)

func setFightState(attacking : bool):
	$hitbox.monitoring = !attacking
	$hitbox.monitorable = !attacking
	$attack.monitoring = attacking
	$attack.monitorable = attacking
func setActive(active : bool):
	$CollisionShape2D.disabled = !active
	$hitbox/CollisionShape2D.disabled = !active
	$attack/CollisionShape2D.disabled = !active

func _on_hitbox_area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	print("ow")

func _on_attack_area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	print("hit")
	if comboTimer > 0 and comboLimit > 0:
		call(str(currentAttack.id, "_combo"))
	else:
		call(str(currentAttack.id, "_return"))

func returnToOrigin():
	setCombatLayer(originCombatLayer)
	gravity = false
	setFightState(false)
	completedTurn = true
	get_node("../../returnTween").interpolate_property(self, "position",
	position, origin, 0.8,
	Tween.TRANS_LINEAR, Tween.EASE_OUT)
	get_node("../../returnTween").start()

func jump(target):
	$AnimationPlayer.stop()
	$AnimationPlayer.play("jump")
	canCombo = true
	comboLimit = 1
	jumpToPosition(target)
func jump_combo():
	canCombo = true
	comboLimit -= 1
	velocity = Vector2(0, -300)
func jump_return():
	velocity = Vector2(-100, -150)
	returning = true
