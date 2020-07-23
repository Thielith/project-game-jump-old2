extends Node2D

func getPositions(amount):
	#Sets array of positions for party
	if amount == 1:
		return [$"3"]
	elif amount == 2:
		return [$"2", $"4"]
	elif amount == 3:
		return [$"1", $"3", $"5"]
