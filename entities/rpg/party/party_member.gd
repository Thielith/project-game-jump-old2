extends entity_rpg
class_name party_member

var maxCombo := 0
var currentCombo := 0
var commandPressedRemeber := 0.0
var comboSuccess := false

var takeInInputs := false

func _process(delta):
	if commandPressedRemeber > 0:
		commandPressedRemeber -= delta
	if takeInInputs:
		_input_process()

func _input_process():
	if Input.is_action_just_pressed("jump") and commandPressedRemeber <= 0:
		commandPressedRemeber = 1.0

func combo():
	if comboSuccess and currentCombo != maxCombo:
		comboSuccess = false
		animationPlayer.play(actionToPerform.function + "_" + actionToPerform.id + "_combo" + str(currentCombo%maxCombo))
		currentCombo += 1
	else:
		animationPlayer.play(actionToPerform.function + "_" + actionToPerform.id + "_end_r")
func endCombo():
	var calc : Vector2 = setMoveVelocity(newLocation, true)
	setVelocity(calc.x, calc.y)
