extends enemy

onready var projectile = preload("res://entities/projectiles/projectile.tscn")

func attack():
	spawnProjectile(projectile)
