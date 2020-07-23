extends Node2D

func setup(icon : String, description : String):
	$back_icon/icon.texture = load(str("res://ui/rpg/action_descriptions/", icon, ".png"))
	$back_text/Label.text = description
