extends party_member

func _physics_process(_delta):
	pass

func _on_Hitbox_area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	if turnEnded:
		print("hurt")

func _on_AttackHitbox_area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	if commandPressedRemeber > 0.79:
		comboSuccess = true
	if actionToPerform.function == "fight":
		if actionToPerform.id == "jump":
			animationPlayer.play("fight_jump_land")
