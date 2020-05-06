extends entity_rpg

onready var enemyPos = get_parent().get_parent().get_node("enemyPos")

var attackPool : Array = []

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	var i = 1
	for posNode in enemyPos.get_children():
		if position < posNode.position + Vector2(3, 3) and position > posNode.position - Vector2(3, 3):
			setCombatLayer(i)
			break
		i += 1
	
	for i in range(attacks.size()):
		for j in range(global_var.rpg_actions.size()):
			if global_var.rpg_actions[j].id == attacks[i]:
				attackPool.append(global_var.rpg_actions[j])
				break
#			if global_var.rpg_actions[j].id == attackSpecials[j] and mana >= global_var.rpg_actions[j].cost:
#				attackPool.append(global_var.rpg_actions[j])
#				break

func _on_Hitbox_area_shape_entered(_area_id, _area, _area_shape, _self_shape):
#	shape_owner_get_owner(shape_find_owner(shape)) 
	if turnEnded:
		print("ow")

func _on_AttackHitbox_area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	setVelocity(-int(velocity.x)%100, false)
	animationPlayer.play("fight_hit_end_r")
