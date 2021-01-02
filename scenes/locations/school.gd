extends Node

onready var world = get_node("/root/Main/WorldEnvironment")

func fade_out(except, avoid):
	world.darken()
	
func fade_in(except, avoid):
	world.lighten()
