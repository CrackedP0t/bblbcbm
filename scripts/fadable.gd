extends Reference

class_name Fadable

const fade_time = 0.5

var fade = 1.0
var fade_direction = 0

func process(delta):
	fade = clamp(fade + fade_direction * delta * 1 / fade_time, 0.0, 1.0)
	return fade
	
func fade_in():
	fade_direction = 1
	
func fade_out():
	fade_direction = -1
