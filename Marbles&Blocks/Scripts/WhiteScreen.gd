extends Sprite

export var duration := 1.0

var time := duration
var direction := true

var level = 1.0

var done := true

func fade_in():
	direction = true
	done = false
	time = level * duration
	
func fade_out():
	direction = false
	done = false
	time = (1-level) * duration

func _process(delta):
	if(done):
		return
	if(direction):
		time += delta
		if(time > duration):
			time = duration
			done = true
		level = time / duration
	else:
		time += delta
		if(time > duration):
			time = duration
			done = true
		level = 1 - time / duration
	modulate.a = level
