extends Camera

onready var offset = translation

func update_position(subject):
	translation = subject + offset

func darken():
	$AnimationPlayer.play("Darken")
	
func lighten():
	$AnimationPlayer.play("Lighten")
