tool

extends Spatial

export var size = Vector2.ONE setget set_size
export var collision_depth = 1.0 setget set_collision_depth
export(int, "Back", "Center", "Front") var collision_side = "Back" setget set_collision_side
export(Texture) var texture = null setget set_texture
export var centered_x = false setget set_centered_x
export var centered_y = false setget set_centered_y
export var pixel_size = 0.01 setget set_pixel_size
export(int, "Disabled", "Discard", "Opaque Pre-Pass") var alpha_cut = 1 setget set_alpha_cut

func set_size(new):
	size = new
	if Engine.editor_hint:
		recalculate()
	
func set_collision_depth(new):
	collision_depth = new
	if Engine.editor_hint:
		recalculate()
		
func set_collision_side(new):
	collision_side = new
	if Engine.editor_hint:
		recalculate()
	
func set_texture(new):
	texture = new
	if Engine.editor_hint:
		recalculate()
	
func set_centered_x(new):
	centered_x = new
	if Engine.editor_hint:
		recalculate()
		
func set_centered_y(new):
	centered_y = new
	if Engine.editor_hint:
		recalculate()
		
func set_pixel_size(new):
	if new != 0:
		pixel_size = new
		if Engine.editor_hint:
			recalculate()
			
func set_alpha_cut(new):
	alpha_cut = new
	if Engine.editor_hint:
		recalculate()

func recalculate():
	var cx = int(centered_x)
	var cy = int(centered_y)
	
	var shape = get_node_or_null("StaticBody/CollisionShape")
	if shape:
		shape.translation = Vector3(int(!cx) * size.x / 2, int(!cy) * size.y / 2,
			(collision_side - 1) * collision_depth)
		shape.shape.extents = Vector3(size.x / 2, size.y / 2, abs(collision_depth))

	var sprite = get_node_or_null("StaticBody/Sprite3D")
	if sprite:
		sprite.texture = texture
		sprite.pixel_size = pixel_size
		sprite.alpha_cut = alpha_cut
		
		if sprite.texture:
			var repeat = sprite.texture.flags & Texture.FLAG_REPEAT
			sprite.region_enabled = repeat
			if repeat:
				sprite.scale = Vector3.ONE
				sprite.region_rect = Rect2(Vector2.ZERO, size / pixel_size)
			else:
				var tex_size = texture.get_size()
				size.x = size.y * (tex_size.x / tex_size.y)
				sprite.scale = Vector3(
					size.y / (tex_size.y * pixel_size),
					size.y / (tex_size.y * pixel_size), 1)
		
		sprite.transform.origin = Vector3(cx * -size.x / 2, cy * -size.y / 2, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	recalculate()
