extends Node2D

var test = 0

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		setHealth(test, 4)
		test += 1
		if test == 5:
			test = 0

func setHealth(value : float, maxValue : float):
	$player.modulate = Color.white
	$hp_bar.value = (value / maxValue) * 100
	$hp_bar/Label.text = str(value, "/", maxValue)
	if value / maxValue == 0:
		$player.material.set_shader_param("outline_color", Color.gray)
		$player.modulate = Color(0.4, 0.4, 0.4)
	elif value / maxValue <= 0.25:
		$player.material.set_shader_param("outline_color", Color.red)
	elif value / maxValue <= 0.5:
		$player.material.set_shader_param("outline_color", Color(1, 0.54, 0))
	else:
		$player.material.set_shader_param("outline_color", Color.green)

func setMagic(value : float, maxValue : float):
	$mp_bar.value = value / maxValue
	$mp_bar/Label.text = str(value, "/", maxValue)
