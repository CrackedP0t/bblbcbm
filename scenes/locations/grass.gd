extends MeshInstance

onready var fader = $Fader

func _process(_delta):
	material_override.set_shader_param("fade", fader.fade)
