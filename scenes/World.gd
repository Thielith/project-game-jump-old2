extends Node2D

onready var transitionPlayer = $main/player/transistion/AnimationPlayer
onready var enemys = $main/enemys
onready var player = $main/player

export var debug := false

func _ready():
	if debug:
		var overlay = load("res://ui/debug.tscn").instance()
		overlay.add_stat("Pos", $main/enemys/slime_medium, "position", false)
		overlay.add_stat("Velocity", $main/enemys/slime_medium, "velocity", false)
		overlay.add_stat("Current State", $main/enemys/slime_medium, "currentState", false)
		overlay.add_stat("isPatroling", $main/enemys/slime_medium, "isPatroling", false)
		overlay.add_stat("sees_player", $main/enemys/slime_medium, "sees_player", true)
		add_child(overlay)

func loadBattle() -> void:
	get_tree().paused = true
	transitionPlayer.play("fade")

func loadScene(path : String) -> void:
	var _unused = get_tree().change_scene(path)
