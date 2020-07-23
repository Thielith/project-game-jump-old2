extends Area2D

func setExtents(x : float, y : float):
	$CollisionShape2D.get_shape().set_extents(Vector2(x, y))
