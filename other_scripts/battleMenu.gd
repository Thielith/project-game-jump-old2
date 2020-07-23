extends Node2D

onready var nodes = $GridContainer.get_children()
var pageAdd = 0

func loadMenu(nodeAmount : int, menuID : int):
	for o in nodes:
		o.visible = false
		o.disabled = true
	for i in range(nodeAmount):
		var buttonTexture
		var buttonName
		var buttonColor
		
		nodes[i].visible = true
		nodes[i].disabled = false
		
		var buttonID = global_var.rpg_menus[menuID][str("button", i+1)]
		for b in global_var.rpg_buttons:
			if b.id == buttonID:
				buttonTexture = load(str("res://ui/rpg/", b.icon, ".png"))
				buttonName = b.text
				nodes[i].buttonDictionary = b
		
		nodes[i].setup(buttonTexture, buttonName)

func loadPlayerMenu(attacks : Array, type : int):
	for o in nodes:
		o.visible = false
		o.disabled = true
	
	var i = 0
	var j = pageAdd
	for _a in range(attacks[type].size() if attacks[type].size() < 5 else 4):
		var buttonTexture
		var buttonName
		var buttonColor
		var buttonCost
		
		nodes[i].visible = true
		nodes[i].disabled = false
		
		for b in global_var.rpg_actions:
			if b.id == attacks[type][j]:
				buttonTexture = load(str("res://ui/rpg/", b.icon, ".png"))
				buttonName = b.text
				buttonColor = Color(b.color)
				buttonCost = b.cost
				nodes[i].buttonDictionary = b
		
		nodes[i].setup(buttonTexture, buttonName, buttonColor, buttonCost)
		i += 1
		j += 1
