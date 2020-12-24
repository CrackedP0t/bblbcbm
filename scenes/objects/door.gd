extends Spatial

const fade_time = 0.5

export var open = false

onready var sprite_3d = $CharacterPlane/Sprite3D

var fade = 1.0
var fade_direction = 0

func _process(delta):
	fade = clamp(fade + fade_direction * delta * 1 / fade_time, 0.0, 1.0)
	sprite_3d.modulate = Color(fade, fade, fade, 1.0)
		
func fade_in():
	fade_direction = 1
	
func fade_out():
	fade_direction = -1

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
