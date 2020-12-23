tool

extends Spatial

class_name CustomPlane, "res://addons/custom_plane/mesh_icon.png"

const fade_time = 0.5

export(Texture) var front_texture = null setget set_front_texture
export(Texture) var back_texture = null setget set_back_texture
export var uv_scale = 1.0 setget set_uv_scale
export var unified_uv_scale = true setget set_unified_uv_scale
export var centered_x = false setget set_centered_x
export var centered_y = false setget set_centered_y
export var dimensions = Vector2(3, 3) setget set_dimensions
export var collision_depth = 0.1 setget set_collision_depth
export var collision_enabled = true
export(Array, Rect2) var rects = [] setget set_rects
export(Vector3) var mesh_rotation setget set_mesh_rotation, get_mesh_rotation
export(Vector3) var mesh_translation setget set_mesh_translation, get_mesh_translation

onready var material = create_material()

var surface_tool
var mesh_instance = MeshInstance.new()
var body = create_body()
var fade = 1.0
var fade_direction = 0

func set_front_texture(new):
	front_texture = new
	if material:
		material.albedo_texture = new

func set_back_texture(new):
	back_texture = new
	material = create_material()
	
func set_uv_scale(new):
	uv_scale = new
	apply_uv_scale(material)

func set_unified_uv_scale(new):
	unified_uv_scale = new
	apply_uv_scale(material)
	
func set_centered_x(new):
	centered_x = new
	gen_mesh()

func set_centered_y(new):
	centered_y = new
	gen_mesh()
	
func set_dimensions(new):
	dimensions = new
	gen_mesh()
	
func set_collision_depth(new):
	collision_depth = new
	
func set_rects(new):
	rects = new
	gen_mesh()
	
func set_mesh_rotation(new):
	mesh_instance.rotation_degrees = new
	
func get_mesh_rotation():
	return mesh_instance.rotation_degrees
	
func set_mesh_translation(new):
	mesh_instance.translation = new

func get_mesh_translation():
	return mesh_instance.translation
	
func apply_uv_scale(m):
	if m:
		if unified_uv_scale:
			m.uv1_scale.x = 1.0 / uv_scale * dimensions.x
			m.uv1_scale.y = 1.0 / uv_scale * dimensions.y
		else:
			m.uv1_scale = Vector3.ONE

func add_rect(x, y, w=1, h=1):
	var uv_y = dimensions.y - y
	
	var x_min = x / dimensions.x - 1
	var y_min = (uv_y - h) / dimensions.y
	var x_max = -1 + (x + w) / dimensions.x
	var y_max = uv_y / dimensions.y
	
	x = x - int(centered_x) * dimensions.x / 2
	y = y - int(centered_y) * dimensions.y / 2
	
	
	surface_tool.add_uv(Vector2(x_max, y_min))
	surface_tool.add_vertex(Vector3(x + w, y + h, 0))
	surface_tool.add_uv(Vector2(x_max, y_max))
	surface_tool.add_vertex(Vector3(x + w, y, 0))
	surface_tool.add_uv(Vector2(x_min, y_max))
	surface_tool.add_vertex(Vector3(x, y, 0))
	
	surface_tool.add_uv(Vector2(x_min, y_max))
	surface_tool.add_vertex(Vector3(x, y, 0))
	surface_tool.add_uv(Vector2(x_min, y_min))
	surface_tool.add_vertex(Vector3(x, y + h, 0))
	surface_tool.add_uv(Vector2(x_max, y_min))
	surface_tool.add_vertex(Vector3(x + w, y + h, 0))
	

func create_body():
	var b = StaticBody.new()
	b.collision_layer = 2
	b.collision_mask = 1
	return b

func create_material():
	var m = SpatialMaterial.new()
	apply_uv_scale(m)
	m.albedo_texture = front_texture
	m.params_cull_mode = SpatialMaterial.CULL_DISABLED
	m.flags_unshaded = true
	
	if back_texture:
		var n = SpatialMaterial.new()
		apply_uv_scale(n)
		n.albedo_texture = back_texture
		n.params_cull_mode = SpatialMaterial.CULL_FRONT
		n.flags_unshaded = true
	
		m.params_cull_mode = SpatialMaterial.CULL_BACK
		m.next_pass = n
	
	return m

func _init():
	add_to_group("Fadable")	

func _ready():
	gen_mesh()
	add_child(body)
	add_child(mesh_instance)
	
func _process(delta):
	fade = clamp(fade + fade_direction * delta * 1 / fade_time, 0.0, 1.0)
	material.albedo_color = Color(fade, fade, fade, 1.0)
	
	if back_texture:
		material.next_pass.albedo_color = Color(fade, fade, fade, 1.0)
		
func fade_in():
	fade_direction = 1
	
func fade_out():
	fade_direction = -1
	
func gen_mesh():
	for shape in body.get_children():
		body.remove_child(shape)
		shape.queue_free()
		
	surface_tool = SurfaceTool.new()
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.set_material(material)
	
	for rect in rects:
		if collision_enabled:
			var col = CollisionShape.new()
			col.translation = Vector3(rect.position.x + rect.size.x / 2 - int(centered_x) * dimensions.x / 2,
				rect.position.y + rect.size.y / 2 - int(centered_y) * dimensions.y / 2,
				0)
			var shape = BoxShape.new()
			shape.extents = Vector3(rect.size.x / 2, rect.size.y / 2, collision_depth)
			
			col.shape = shape
			body.add_child(col)
		
		add_rect(rect.position.x, rect.position.y, rect.size.x, rect.size.y)
	
	mesh_instance.mesh = surface_tool.commit()
