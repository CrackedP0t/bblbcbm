extends Camera

onready var offset = translation

func update_position(subject):
	translation = subject + offset
