extends Node2D

onready var transitionPlayer := get_node("transition/AnimationPlayer")
onready var uiAnimationPlayer := get_node("ui/AnimationPlayer")
onready var portrait = get_node("ui/background/portrait")

onready var enemyBasePositions := []
onready var partyBasePositions := []
var currentEnemyAmount : int = global_var.battleEnemys.size()
var currentPartyAmount : int = global_var.battleParty.size()
onready var enemies : Array
onready var party : Array

var actionMenu := Array()
onready var uiParty := get_node("ui/partyMembers/member/list").get_children()
onready var uiActionIcons := [[get_node("ui/actions/icons/1"),get_node("ui/actions/icons/2"),get_node("ui/actions/pageNavigation/arrowMinus")],
							[get_node("ui/actions/icons/3"),get_node("ui/actions/icons/4"),get_node("ui/actions/pageNavigation/arrowPlus")]]
onready var uiActionText := [[get_node("ui/actions/text/1"),get_node("ui/actions/text/2")],
							[get_node("ui/actions/text/3"),get_node("ui/actions/text/4")]]
onready var uiActionTextImages := [[get_node("ui/actions/textImages/1"),get_node("ui/actions/textImages/2")],
							[get_node("ui/actions/textImages/3"),get_node("ui/actions/textImages/4")]]
onready var enemyArrow := get_node("arrowBattlefield")

#0 = party, 1 = action, 2 = enemy
var currentChoiceState := 0
var thingSelected := [0, [0,0], 0]
var currentMenu := 0
var pageIndex := 0

var enemyTurn := false
var processingAttack := true
var enemyIndex := -1

func setArrays() -> void:
	#Sets array of positions for party
	if currentPartyAmount == 1:
		partyBasePositions = [get_node("partyPos/3")]
	elif currentPartyAmount == 2:
		partyBasePositions = [
		get_node("partyPos/2"),
		get_node("partyPos/4")]
	elif currentPartyAmount == 3:
		partyBasePositions = [
		get_node("partyPos/1"),
		get_node("partyPos/3"),
		get_node("partyPos/5")]
	
	#Sets array of positions for enemys
	if currentEnemyAmount == 1:
		enemyBasePositions = [get_node("enemyPos/3")]
	elif currentEnemyAmount == 2:
		enemyBasePositions = [
		get_node("enemyPos/2"),
		get_node("enemyPos/4")]
	elif currentEnemyAmount == 3:
		enemyBasePositions = [
		get_node("enemyPos/1"),
		get_node("enemyPos/3"),
		get_node("enemyPos/5")]
func spawn() -> void: #Spawns party and enemys based on global_var arrays
	var i : int = 0
	for e in global_var.battleEnemys:
		var enemy = e.instance()
		get_node("enemys").add_child(enemy)
		enemy.position = enemyBasePositions[i].position
		enemy.origin = enemyBasePositions[i].position
		enemy.combatLayer = int(enemyBasePositions[i].get_name())
		enemy.turnEnded = true
		i += 1
	enemies = get_node("enemys").get_children()
	
	i = 0
	for p in global_var.battleParty:
		var member = p.instance()
		get_node("party").add_child(member)
		member.position = partyBasePositions[i].position
		member.origin = partyBasePositions[i].position
		member.combatLayer = int(partyBasePositions[i].get_name())
		i += 1
	party = get_node("party").get_children()
	
	for i in range(party.size()):
		uiParty[i].visible = true
	portrait.get_node("AnimationPlayer").play("idle")

func _ready() -> void:
	setArrays()
	spawn()
	updateUI()
	loadMenu(0)
	transitionPlayer.play_backwards("fade")
	uiAnimationPlayer.play("show")

func _process(_delta) -> void:
	if Input.is_action_just_pressed("interact"):
		pass
	if enemyTurn and not processingAttack:
		processingAttack = true
		enemyIndex += 1
		if enemyIndex > enemies.size() - 1:
			checkPartyStatus()
		else:
			enemies[enemyIndex].actionToPerform = enemies[enemyIndex].attackPool[randi()%enemies[enemyIndex].attackPool.size()]
			if enemies[enemyIndex].actionToPerform.function != "none":
				enemies[enemyIndex].target = party[randi()%party.size()]
				performAttacks(enemies[enemyIndex], enemies[enemyIndex].target)
			else:
				enemies[enemyIndex].turnEnded = true
				processingAttack = false

func _input(event) -> void:
	if not event is InputEventMouseMotion:
		if not enemyTurn:
			if Input.is_action_just_pressed("up"):
				if currentChoiceState == 0 and thingSelected[0] > 0:
					thingSelected[0] -= 1
					updateUI()
				elif currentChoiceState == 1 and thingSelected[1][1] > 0 and thingSelected[1][0] < actionMenu[0].size():
					thingSelected[1][1] -= 1
					updateUI()
			elif Input.is_action_just_pressed("down"):
				if currentChoiceState == 0 and thingSelected[0] + 1 < party.size():
					thingSelected[0] += 1
					updateUI()
				elif currentChoiceState == 1 and thingSelected[1][1] < actionMenu.size() - 1 and thingSelected[1][0] < actionMenu[1].size():
					thingSelected[1][1] += 1
					updateUI()
			elif Input.is_action_just_pressed("left"):
				if currentChoiceState == 2 and thingSelected[currentChoiceState] > 0:
					thingSelected[2] -= 1
					updateUI()
				elif currentChoiceState == 1 and thingSelected[1][0] > 0:
					thingSelected[1][0] -= 1
					updateUI()
			elif Input.is_action_just_pressed("right"):
				if currentChoiceState == 2 and thingSelected[currentChoiceState] + 1 < enemies.size():
					thingSelected[2] += 1
					updateUI()
				elif currentChoiceState == 1 and thingSelected[1][0] + 1 < actionMenu[thingSelected[1][1]].size():
					thingSelected[1][0] += 1
					updateUI()
			
			elif Input.is_action_just_pressed("jump"):
				if currentChoiceState == 0:
					if not party[thingSelected[0]].turnEnded:
						currentChoiceState += 1
				elif currentChoiceState == 1:
					var selected = actionMenu[thingSelected[1][1]][thingSelected[1][0]].duplicate()
					if selected.function.begins_with("load"):
						currentMenu = int(selected.function)
						pageIndex = 0
						loadMenu(currentMenu)
						if thingSelected[1] != [0, 0]:
							thingSelected[1] = [0, 0]
					elif selected.function.begins_with("page"):
						selected.function = selected.function.replace("page", "")
						if selected.function == "Plus":
							pageIndex += 1
							loadMenu(currentMenu)
						elif selected.function == "Minus":
							pageIndex -= 1
							loadMenu(currentMenu)
					elif selected.function == "fight":
						currentChoiceState += 1
						party[thingSelected[0]].actionToPerform = selected
						party[thingSelected[0]].maxCombo = int(selected.comboMax)
					elif selected.function == "defend":
						uiParty[thingSelected[0]].self_modulate = Color(0.5, 0.5, 0.5, 1)
						party[thingSelected[0]].turnEnded = true
						currentChoiceState = 0
						checkPartyStatus()
						pass
				elif currentChoiceState == 2:
					uiAnimationPlayer.play("hide")
					uiParty[thingSelected[0]].self_modulate = Color(0.5, 0.5, 0.5, 1)
					party[thingSelected[0]].takeInInputs = true
					party[thingSelected[0]].target = enemies[thingSelected[2]]
					currentChoiceState = -1
					performAttacks(party[thingSelected[0]], party[thingSelected[0]].target)
				updateUI()
			elif Input.is_action_just_pressed("run"):
				if currentChoiceState == 1:
					if actionMenu[thingSelected[1][1]][thingSelected[1][0]].previous == -5:
						currentChoiceState -= 1
						uiActionIcons[thingSelected[1][1]][thingSelected[1][0]].get_node("AnimationPlayer").play("deselect")
					else:
						pageIndex = 0
						loadMenu(actionMenu[thingSelected[1][1]][thingSelected[1][0]].previous)
						if thingSelected[1] != [0, 0]:
							thingSelected[1] = [0, 0]
				elif currentChoiceState == 2:
					currentChoiceState -= 1
					enemyArrow.visible = false
				updateUI()
		else:
			if Input.is_action_just_pressed("jump"):
				enemies[enemyIndex].target.animationPlayer.play("dodge")
func updateUI() -> void:
	enemyArrow.visible = false
	
	if currentChoiceState == 0:
		for i in range(uiParty.size()):
			if i != thingSelected[0]:
				if uiParty[i].get_node("AnimationPlayer").assigned_animation == "select":
					uiParty[i].get_node("AnimationPlayer").play("deselect")
		if uiParty[thingSelected[0]].get_node("AnimationPlayer").assigned_animation != "select":
			uiParty[thingSelected[0]].get_node("AnimationPlayer").play("select")
		portrait.texture = party[thingSelected[0]].portrait
	
	elif currentChoiceState == 1:
		for i in range(uiActionIcons.size()):
			for j in range(uiActionIcons[i].size()):
				if uiActionIcons[i][j].get_node("AnimationPlayer").assigned_animation == "select":
					uiActionIcons[i][j].get_node("AnimationPlayer").play("deselect")
		uiActionIcons[thingSelected[1][1]][thingSelected[1][0]].get_node("AnimationPlayer").play("select")
	
	elif currentChoiceState == 2:
		enemyArrow.visible = true
		enemyArrow.position = enemies[thingSelected[2]].position - Vector2(0, enemies[thingSelected[2]].get_node("Sprite").texture.get_height() - 10)

func loadMenu(id : int) -> void:
	actionMenu.clear()
	setVisibility(uiActionIcons, false)
	setVisibility(uiActionText, false)
	setVisibility(uiActionTextImages, false)
	
	var menuLoading = global_var.rpg_menus[0]
	if id != 0:
		for i in range(global_var.rpg_menus.size()):
			if global_var.rpg_menus[i].id == id:
				menuLoading = global_var.rpg_menus[id]
				break
	
	var buttonsLoading = []
	var n = 0
	for i in range(0, 4):
		if menuLoading.loadFromParty:
			for j in range(global_var.rpg_actions.size()):
				if i + (4*pageIndex) < party[thingSelected[0]][menuLoading["button" + str(i + 1)]].size():
					if global_var.rpg_actions[j].id == party[thingSelected[0]][menuLoading["button" + str(i + 1)]][i + (4*pageIndex)]:
						buttonsLoading.append(global_var.rpg_actions[j])
						break
		else:
			for j in range(global_var.rpg_buttons.size()):
				if global_var.rpg_buttons[j].id == menuLoading["button" + str(i + 1)]:
					buttonsLoading.append(global_var.rpg_buttons[j])
					break
		n += 1
		if n == 2 and not buttonsLoading.empty():
			actionMenu.append(buttonsLoading)
			buttonsLoading = []
			n = 0
	
	if menuLoading.loadFromParty and party[thingSelected[0]][menuLoading["button1"]].size() > 4:
		if pageIndex != 0:
			actionMenu[0].append({"icon":"arrow5", "text":"null", "previous":1, "function":"pageMinus"})
			get_node("ui/actions/pageNavigation/arrowMinus").visible = true
		if pageIndex + 1 < ceil(party[thingSelected[0]][menuLoading["button1"]].size()/4):
			actionMenu[1].append({"icon":"arrow6", "text":"null", "previous":1, "function":"pagePlus"})
			get_node("ui/actions/pageNavigation/arrowPlus").visible = true
		
		if thingSelected[1][1] == 0 and actionMenu[0].size() == 2:
			thingSelected[1][1] = 1
		elif thingSelected[1][1] == 1 and actionMenu[1].size() == 2:
			thingSelected[1][1] = 0
	
	for i in range(actionMenu.size()):
		for j in range(actionMenu[i].size()):
			uiActionIcons[i][j].texture = load("res://ui/rpg/" + actionMenu[i][j].icon + ".png")
			uiActionIcons[i][j].visible = true
			if actionMenu[i][j].text == "image":
				uiActionTextImages[i][j].visible = true
			elif actionMenu[i][j].text == "null":
				pass
			else:
				uiActionText[i][j].text = actionMenu[i][j].text
				uiActionText[i][j].visible = true
func setVisibility(reference, boolen) -> void:
	for i in reference:
		for j in i:
			j.visible = boolen

func performAttacks(attacker, target) -> void:
	attacker.setCombatState(true, true, true)
	target.setCombatState(true, true, true)
	target.setCombatLayer(target.combatLayer)
	target.enableGravity = true
	attacker.targetLocation = target.position - Vector2(0, (target.get_node("Sprite").texture.get_height() / target.get_node("Sprite").vframes) / 2)
	attacker.animationPlayer.play("active")
	target.animationPlayer.play("active")
	
	if attacker.actionToPerform.movePosition:
		attacker.newLocation = target.position - Vector2(1-2*int(enemyTurn), 1) * Vector2((target.get_node("Sprite").texture.get_width() / target.get_node("Sprite").hframes) + 110, 0)
		attacker.newCombatLayer = target.combatLayer
		attacker.moveToLocation()
	else:
		attacker.newCombatLayer = attacker.combatLayer
		attacker.performAction()

func checkPartyStatus() -> void:
	var partyFinished := true
	if not enemyTurn:
		for i in party:
			if not i.turnEnded:
				partyFinished = false
	elif enemyTurn:
		for i in enemies:
			if not i.turnEnded:
				partyFinished = false
	
	if partyFinished:
		enemyTurn = !enemyTurn
		if enemyTurn:
			enemyIndex = -1
			processingAttack = false
			uiAnimationPlayer.play("hide")
			for i in enemies:
				i.turnEnded = false
				i.returning = false
		else:
			for i in party:
				i.turnEnded = false
			for j in uiParty:
				j.self_modulate = Color(1, 1, 1, 1)
			currentChoiceState = 0
			thingSelected = [0, [0,0], 0]
			uiAnimationPlayer.play("show")
			updateUI()
