extends Node2D

var allies
onready var allySpawnPositions = $allySpawnPos.getPositions(global_var.battleAllies.size())
var opponents
onready var opponentSpawnPositions = $opponentSpawnPos.getPositions(global_var.battleOpponents.size())

var selectedAlly := 0
var allyAttackData

var selectedOpponent := 0
var opponentAttackData

var allyTurn := true

func _ready():
	get_tree().paused = false
	spawn()
	$transition/AnimationPlayer.play_backwards("fade")
	
#	var overlay = load("res://ui/debug.tscn").instance()
#	overlay.add_stat("selectedAlly", self, "selectedAlly", false)
#	overlay.add_stat("comboTimer", allies[selectedAlly], "comboTimer", false)
#	overlay.add_stat("comboLimit", allies[selectedAlly], "comboLimit", false)
#	overlay.add_stat("returning", allies[selectedAlly], "returning", false)
#	overlay.add_stat("completedTurn", allies[selectedAlly], "completedTurn", false)
#	add_child(overlay)

func spawn() -> void: #Spawns party and enemys based on global_var arrays
	var i : int = 0
	for p in global_var.battleAllies:
		var ally = p.instance()
		ally.position = allySpawnPositions[i].global_position
		ally.origin = allySpawnPositions[i].global_position
		ally.originCombatLayer = int(allySpawnPositions[i].name)
		ally.setCombatLayer(int(allySpawnPositions[i].name))
		ally.get_node("AnimationPlayer").play("idle")
		ally.setFightState(false)
		ally.setActive(false)
		$allies.add_child(ally)
		i += 1
	allies = $allies.get_children()
	
	i = 0
	for e in global_var.battleOpponents:
		var opponent = e.instance()
		opponent.position = opponentSpawnPositions[i].global_position
		opponent.origin = opponentSpawnPositions[i].global_position
		opponent.originCombatLayer = int(opponentSpawnPositions[i].name)
		opponent.setCombatLayer(int(opponentSpawnPositions[i].name))
		opponent.get_node("AnimationPlayer").play("idle")
		opponent.setFightState(false)
		opponent.setActive(false)
		$opponents.add_child(opponent)
		i += 1
	opponents = $opponents.get_children()

func _process(_delta):
	pass

func setUI(menuID : int):
	for i in $ui/menu/GridContainer.get_children():
		i.visible = false
#	$ui/menu.position = allySpawnPositions[selectedAlly].global_position + Vector2(30, -allies[selectedAlly].spriteHeight - 20)
	$ui.loadMenu(menuID)

func fight(attackData : Dictionary):
	allies[selectedAlly].setActive(true)
	opponents[selectedOpponent].setActive(true)
	
	allyAttackData = attackData
	if attackData.movePosition:
		var newPosition : Vector2 = opponents[selectedOpponent].position
		if attackData.reach == "any":
			newPosition -= Vector2(120, 0)
		allies[selectedAlly].get_node("AnimationPlayer").play("move")
		
		$moveTween.interpolate_property(allies[selectedAlly], "position",
		allies[selectedAlly].origin, newPosition, 0.8,
		Tween.TRANS_LINEAR, Tween.EASE_OUT)
		$moveTween.start()
	print(attackData)

func resetUI():
	$ui.selectedMenuOption = 0
	$ui.lastMenuLoaded = [-1]
	$ui.loadingDataDriven = false
	$ui.isAllySelected = false
	$ui.menuType = 0
	$ui.popupShown = false
	$ui/selector.visible = true

func _on_moveTween_tween_completed(_object, _key):
	if allyTurn:
		allies[selectedAlly].setCombatLayer(opponents[selectedOpponent].originCombatLayer)
		allies[selectedAlly].setFightState(true)
		opponents[selectedOpponent].setFightState(false)
		allies[selectedAlly].currentAttack = allyAttackData
		allies[selectedAlly].call(allyAttackData.id, opponents[selectedOpponent].position - Vector2(0, opponents[selectedOpponent].spriteHeight))

func _on_returnTween_tween_completed(object, key):
	allies[selectedAlly].returning = false
	allies[selectedAlly].get_node("AnimationPlayer").play("idle")
	allies[selectedAlly].get_node("Sprite").modulate = Color(0.35, 0.35, 0.35)
	allies[selectedAlly].setActive(false)
	opponents[selectedOpponent].setActive(false)
	resetUI()
	$ui.set_process(true)
