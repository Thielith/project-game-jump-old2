extends Node2D

onready var transitionPlayer = get_node("transistion/AnimationPlayer")
onready var enemys = $main/enemys
onready var player = $main/player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func loadBattle() -> void:
	player.pauseGame = true
	for e in enemys.get_children():
		e.pauseGame = true
	transitionPlayer.play("fade")

func loadScene(path) -> void:
	print(path)
	get_tree().change_scene(path)
