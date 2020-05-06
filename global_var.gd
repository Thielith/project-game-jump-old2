extends Node

var gravity : float = 10.0
var maxFallSpeed : int = 500

#preloading all enemys
var player = preload("res://entities/rpg/party/player/player_rpg.tscn")
#var test_dummy = preload("res://entities/rpg/enemies/test_dummy.tscn")
var slime = preload("res://entities/rpg/enemies/slimes/slime_small.tscn")
var slime_medium = preload("res://entities/rpg/enemies/slimes/slime_medium.tscn")

var battleParty : Array = [player]
var battleEnemys : Array = [slime_medium]
var rpg_buttons := []
var rpg_menus := []
var rpg_actions := []

func _ready():
	rpg_buttons = readFile("rpg_buttons")
	rpg_menus = readFile("rpg_menus")
	rpg_actions = readFile("rpg_actions")

func readFile(path):
	var dict = {}
	var file = File.new()
	file.open("res://spreadsheets/" + path + ".json", file.READ)
	var text = file.get_as_text()
	dict = parse_json(text)
	file.close()
	return dict
