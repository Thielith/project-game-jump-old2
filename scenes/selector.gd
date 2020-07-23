extends Sprite

var tweenCompleted := true

func _on_Tween_tween_completed(object, key):
	texture = load("res://ui/rpg/arrowDown.png")
	tweenCompleted = true
