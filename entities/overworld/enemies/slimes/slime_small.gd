extends enemy

func attack():
	jump()
	velocity = Vector2(300 * playerDirection, -220)

func _on_hitbox_area_shape_entered(_area_id, _area, _area_shape, _self_shape):
#	print("enemy hurt")
	switchState(hitstun, true)

func _on_attackHitbox_area_shape_entered(_area_id, _area, _area_shape, _self_shape):
#	print("enemy hit something")
	velocity.x = -velocity.x/2.0
	switchState(hit, false)
