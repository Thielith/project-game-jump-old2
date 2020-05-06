extends enemy

const projectile = preload("res://entities/projectiles/slime_projectile_small.tscn")

func _ready():
	chase_speed = player.walk_speed * 1.5 - 15

func _process(delta):
	if currentState[0] == chase:
		max_speed = chase_speed
		if not playingTimedAnimation:
			if abs(player.position.x - position.x) < 32 and player.position.y < position.y - 10 and groundDirection != -5:
				move(0, 0)
				snapToFloor = false
				playAnimation(jumping)
			elif abs(player.position.x - position.x) < 128 and player.position.y >= position.y - 10 and groundDirection != -5:
				move(0, 0)
				snapToFloor = false
				playAnimation(attacking)
			else:
				chase()
	else:
		max_speed = walk_speed

func animationPlayerFunction(function):
	if function == "none":
		playingTimedAnimation = false
	else:
		playingTimedAnimation = true
	
	if function == "jump":
		jump(0)
		print(velocity)
	elif function == "attack":
		var activeProjectile = projectile.instance()
		get_parent().get_parent().add_child(activeProjectile)
		activeProjectile.position = position + Vector2(18 * playerDirection, -18)
		activeProjectile.launch(playerDirection)

func playAnimation(animationName):
	if animationPlayer.current_animation != animationName:
		animationPlayer.stop()
		animationPlayer.play(animationName)

func _on_Hitbox_area_shape_entered(area_id, area, area_shape, self_shape):
	var collider = area.get_parent()
	if collider.get_collision_layer_bit(12) == true:
		if collider.get_collision_layer_bit(3) == true:
			hitstun(collider)
	else:
		loadBattle()
