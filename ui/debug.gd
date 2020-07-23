extends CanvasLayer

var stats := []

func _ready():
	pass # Replace with function body.

func add_stat(name, object, ref, method : bool):
	stats.append([name, object, ref, method])

func _process(_delta):
	var label_text = ""
	
	var fps = Engine.get_frames_per_second()
	label_text += str("FPS: ", fps, "\n")
	
	var mem = OS.get_static_memory_usage()
	label_text += str("Static Memory: ", String.humanize_size(mem), "\n")
	
	for s in stats:
		var value = null
		if s[1] and weakref(s[1]).get_ref():
			if s[3]:
				value = s[1].call(s[2])
			else:
				value = s[1].get(s[2])
		label_text += str(s[0], ": ", value)
		label_text += "\n"
	
	$Label.text = label_text
