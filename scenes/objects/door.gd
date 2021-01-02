extends Spatial

export var open = false

onready var sprite_3d = $CharacterPlane/Sprite3D
onready var fader = $Fader

func _process(_delta):
	var fade = fader.fade
	sprite_3d.modulate = Color(fade, fade, fade, 1.0)
	
func interact(i_transform):
	if open:
		$AnimationPlayer.play("Close " + open)
		open = false
	else:
		var direction = i_transform.origin - transform.origin
		if direction.dot(transform.basis.z) > 0:
			open = "Behind"
		else:
			open = "Front"
		$AnimationPlayer.play("Open " + open)
	
func enable_collision():
	$CharacterPlane.collision_enabled = true

func disable_collision():
	$CharacterPlane.collision_enabled = false
