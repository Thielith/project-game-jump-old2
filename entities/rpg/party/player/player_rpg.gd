extends party_member

func _ready():
	attackSpecials = ["jump", "jump", "jump", "jump",
					"jump", "jump", "jump", "jump",
					"jump", "jump", "jump", "jump",
					"jump", "jump", "jump", "jump",
					"jump", "jump", "jump", "jump",
					"jump", "jump", "jump", "jump",
					"jump", "jump", "jump", "jump"]

func _physics_process(_delta):
	if Input.is_action_just_pressed("interact"):
		print("Velocity: " + str(velocity))
		print("Combat Layer: " + str(combatLayer))
#	print(returning)

func _on_Hitbox_area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	if turnEnded:
		print("hurt")

func _on_AttackHitbox_area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	if commandPressedRemeber > 0.79:
		comboSuccess = true
	if actionToPerform.function == "fight":
		if actionToPerform.id == "jump":
			animationPlayer.play("fight_jump_land")
