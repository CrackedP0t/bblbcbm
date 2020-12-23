extends Spatial

export var open = false

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
