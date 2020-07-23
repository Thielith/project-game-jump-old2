extends Control

var basePosition : Vector2
var buttonDictionary : Dictionary
var disabled := false

func _ready():
	basePosition = rect_position

func setup(iconTexture : Texture, name: String, color : Color = Color.white, cost : int = 0):
	$icon.texture = iconTexture
	$name.text = name
	$background.modulate = color
	$cost.visible = false
	if cost != 0:
		$cost.visible = true
		$cost.text = str(cost)

func select():
	$Tween.interpolate_property(self, "rect_position",
	basePosition, basePosition+Vector2(10, 0), 0.1,
	Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()

func deselect():
	$Tween.interpolate_property(self, "rect_position",
	basePosition+Vector2(10, 0), basePosition, 0.1,
	Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.start()
