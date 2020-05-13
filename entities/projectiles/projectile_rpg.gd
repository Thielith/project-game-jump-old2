extends KinematicBody2D

export var hasGravity : bool
export var startBattle : bool
var velocity : Vector2 = Vector2.ZERO
var gravity = global_var.gravity

func _physics_process(delta) -> void:
	if hasGravity:
		velocity.y += gravity
	var collision = move_and_collide(velocity * delta)
	handleCollision(collision)

func handleCollision(collision : KinematicCollision2D) -> void:
	if collision != null:
		get_parent().returning = true
		get_parent().endTurn()
		get_parent().remove_child(self)
