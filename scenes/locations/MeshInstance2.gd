extends MeshInstance

var fadable

func _init():
	fadable = Fadable.new()

func _process(delta):
	var fade = fadable.process(delta)
	material_override.set_shader_param("fade", fade)

func fade_in():
	fadable.fade_in()
	
func fade_out():
	fadable.fade_out()
