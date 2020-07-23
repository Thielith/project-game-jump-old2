extends KinematicBody2D

var hasGravity : bool
var loadsBattle := true
var velocity := Vector2.ZERO
var gravity = global_var.gravity

func _physics_process(delta) -> void:
	if hasGravity:
		velocity.y += gravity
	var _unused = move_and_collide(velocity * delta)

func _on_Hitbox_area_shape_entered(_area_id, _area, _area_shape, _self_shape):
	if not loadsBattle:
		pass
	self.queue_free()
