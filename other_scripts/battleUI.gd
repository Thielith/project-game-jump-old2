extends Node2D

var selectedMenuOption := 0
var lastMenuLoaded := [-1]
var loadingDataDriven := false
var isAllySelected := false
var menuType := 0
var popupShown := false
var hoveredButtonData : Dictionary

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	selectAlly()

func _process(_delta):
	#Opens pop-up menu
	if Input.is_action_just_pressed("interact"):
		if not popupShown:
			popupShown = true
			$pop_up/AnimationPlayer.play("show")
		else:
			popupShown = false
			$pop_up/AnimationPlayer.play_backwards("show")
		print(menuType)
	
	#All menu navigation
	if Input.is_action_just_pressed("up") and isAllySelected and menuType != 2:
		if selectedMenuOption-1 >= 0:
			selectedMenuOption -= 1
			displaySelection()
		elif loadingDataDriven and $menu.pageAdd-1 >= 0:
			$menu.pageAdd -= 1
			$menu.loadPlayerMenu(get_parent().allies[get_parent().selectedAlly].attacks, menuType)
			selectedMenuOption = 0
			displaySelection()
	elif Input.is_action_just_pressed("down") and isAllySelected and menuType != 2:
		if selectedMenuOption+1 < $menu.nodes.size() and $menu.nodes[selectedMenuOption+1].visible:
			selectedMenuOption += 1
			displaySelection()
		elif loadingDataDriven and $menu.pageAdd+4 < get_parent().allies[get_parent().selectedAlly].attacks[menuType].size():
			$menu.pageAdd += 1
			$menu.loadPlayerMenu(get_parent().allies[get_parent().selectedAlly].attacks, menuType)
			selectedMenuOption = 3
			displaySelection()
	elif Input.is_action_just_pressed("left"):
		if get_parent().selectedAlly + 1 < get_parent().allies.size() and not isAllySelected:
			get_parent().selectedAlly += 1
			selectAlly()
		elif get_parent().selectedOpponent - 1 >= 0 and menuType == 2:
			get_parent().selectedOpponent -= 1
			selectOpponent()
	elif Input.is_action_just_pressed("right"):
		if get_parent().selectedAlly - 1 >= 0 and not isAllySelected:
			get_parent().selectedAlly -= 1
			selectAlly()
		elif get_parent().selectedOpponent + 1 < get_parent().opponents.size() and menuType == 2:
			get_parent().selectedOpponent += 1
			selectOpponent()
	
	#Selecting options and backing out
	if Input.is_action_just_pressed("jump"):
		if not isAllySelected:
			if not get_parent().allies[get_parent().selectedAlly].completedTurn:
				$menu.loadMenu(4, 0)
				get_parent().setUI(0)
				$menu.visible = true
				isAllySelected = true
			elif $selector.tweenCompleted:
				$selector.tweenCompleted = false
				$selector.texture = load("res://ui/rpg/cancel.png")
				$selector/Tween.interpolate_property($selector, "position",
				$selector.position - Vector2(10, 0), $selector.position, 0.4,
				Tween.TRANS_ELASTIC, Tween.EASE_OUT)
				$selector/Tween.start()
		elif not loadingDataDriven:
			runMenuFunction(hoveredButtonData.function, hoveredButtonData.numData)
			displaySelection()
		elif menuType != 2:
			menuType = 2
			$enemySelector.visible = true
			selectOpponent()
		else:
			if hoveredButtonData.function == "fight":
				get_parent().fight(hoveredButtonData)
				showPlayerUI(false)
				set_process(false)
	elif Input.is_action_just_pressed("run"):
		if lastMenuLoaded.size() > 1:
			if menuType == 2:
				menuType = 0
				$enemySelector.visible = false
			elif lastMenuLoaded[1] != -1:
				selectedMenuOption = 0
				$menu.pageAdd = 0
				loadMenu(lastMenuLoaded[1])
				lastMenuLoaded.pop_front()
				lastMenuLoaded.pop_front()
				displaySelection()
			elif isAllySelected:
				isAllySelected = false
				$menu.visible = false
				lastMenuLoaded.pop_front()

func runMenuFunction(function, value):
	call(function, value)

func displaySelection():
	for s in $menu.nodes:
		if s.get_node("state").assigned_animation == "select":
			s.get_node("state").play("deselect")
			s.deselect()
	$menu.nodes[selectedMenuOption].get_node("state").play("select")
	$menu.nodes[selectedMenuOption].select()
	hoveredButtonData = $menu.nodes[selectedMenuOption].buttonDictionary
	$pop_up/back_text/Label.text = hoveredButtonData.description
	$pop_up/back_icon/icon.texture = load(str("res://ui/rpg/action_descriptions/", hoveredButtonData.descIcon,".png"))
func selectAlly():
	var allySelected = get_parent().allies[get_parent().selectedAlly]
	$selector.position = allySelected.get_node("selectorPos").global_position
func selectOpponent():
	var opponentSelected = get_parent().opponents[get_parent().selectedOpponent]
	$enemySelector.position = opponentSelected.get_node("selectorPos").global_position

func loadMenu(menuID):
	loadingDataDriven = false
	lastMenuLoaded.push_front(menuID)
	displaySelection()
	$menu.loadMenu(global_var.rpg_menus[menuID].size()-2, menuID)
	$pop_up/back_text/Label.valign = Label.VALIGN_CENTER

func loadPlayerMenu(type):
	loadingDataDriven = true
	menuType = type
	lastMenuLoaded.push_front(-1)
	displaySelection()
	$menu.loadPlayerMenu(get_parent().allies[get_parent().selectedAlly].attacks, type)
	$pop_up/back_text/Label.valign = Label.VALIGN_TOP

func showPlayerUI(show):
	$menu.visible = show
	$selector.visible = show
	$enemySelector.visible = show
	if show and not popupShown:
		$pop_up/AnimationPlayer.play("show")
	elif popupShown:
		$pop_up/AnimationPlayer.play_backwards("show")
	popupShown = show
