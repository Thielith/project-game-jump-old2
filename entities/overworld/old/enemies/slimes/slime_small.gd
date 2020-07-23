extends enemy_o

func _ready():
	chase_speed = player.walk_speed * 1.5 - 10

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
		if player.position.x > position.x:
			jump(300)
		if player.position.x < position.x:
			jump(-300)

func playAnimation(animationName):
	if animationPlayer.current_animation != animationName:
		animationPlayer.stop()
		animationPlayer.play(animationName)

func _on_Hitbox_area_shape_entered(area_id, area, area_shape, self_shape):
	var collider = area.get_parent()
	if collider.groundDirection == -5 and collider.position.y < position.y:
		hitstun(collider)
	elif groundDirection == -5:
		if position.x < collider.position.x:
			launch(-200, -80)
		else:
			launch(200, -80)
