extends Node

class_name Fader

const fade_time = 0.5

export var fade = 1.0
var fade_direction = 0

func _ready():
	self.name = "Fader"
	add_to_group("Faders")

func _process(delta):
	fade = clamp(fade + fade_direction * delta * 1 / fade_time, 0.0, 1.0)
	
func fade_in():
	fade_direction = 1
	
func fade_out():
	fade_direction = -1
