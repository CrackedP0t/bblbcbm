tool

extends KinematicBody

export var size = Vector2.ONE setget set_size
export(int, "Height", "Width", "Disable") var lock_scale = 0 setget set_lock_scale
export var collision_enabled = true
export var collision_depth = 0.1
export(Rect2) var collision_rect = Rect2(0, 0, 1, 1)
export(int, "Back", "Center", "Front") var collision_side = 1
export(Texture) var texture = null setget set_texture
export var centered_x = true setget set_centered_x
export var centered_y = false setget set_centered_y
export(int, "Disabled", "Discard", "Opaque Pre-Pass") var alpha_cut = 0 setget set_alpha_cut
export var sprite_centered = true setget set_sprite_centered
export(Vector3) var sprite_translation = Vector3.ZERO setget set_sprite_translation
export(Vector3) var sprite_rotation = Vector3.ZERO setget set_sprite_rotation

onready var fader = get_node_or_null("Fader")

func _process(_delta):
	if fader:
		var fade = fader.fade
		$Sprite3D.modulate = Color(fade, fade, fade)

func set_size(new):
	size = new
	recalculate()
	
func set_lock_scale(new):
	lock_scale = new
	recalculate()
	
func set_texture(new):
	texture = new
	recalculate()
	
func set_centered_x(new):
	centered_x = new
	recalculate()
		
func set_centered_y(new):
	centered_y = new
	recalculate()
			
func set_alpha_cut(new):
	alpha_cut = new
	recalculate()
	
func set_sprite_centered(new):
	sprite_centered = new
	recalculate()
		
func set_sprite_translation(new):
	sprite_translation = new
	recalculate()
		
func set_sprite_rotation(new):
	sprite_rotation = new
	recalculate()

func recalculate():
	var trans = Vector3(int(!centered_x) * size.x / 2, int(!centered_y) * size.y / 2, 0)
	
	var shape = get_node_or_null("CollisionShape")
	if shape:
		var r = collision_rect
		shape.disabled = !collision_enabled
		shape.translation = trans + Vector3(r.position.x, r.position.y,
			(collision_side - 1) * collision_depth)
		shape.shape.extents = Vector3((r.size.x * size.x) / 2,
			(r.size.y * size.y) / 2, collision_depth)

	var sprite = get_node_or_null("Sprite3D")
	if sprite:
		sprite.texture = texture
		sprite.alpha_cut = alpha_cut
		sprite.centered = sprite_centered
		
		if sprite.texture:
			var tex_size = texture.get_size()
			
			if lock_scale == 0:
				size.x = size.y * (tex_size.x / tex_size.y)
				sprite.scale = Vector3(
					size.y / (tex_size.y * sprite.pixel_size),
					size.y / (tex_size.y * sprite.pixel_size), 1)
			elif lock_scale == 1:
				size.y = size.x * (tex_size.y / tex_size.x)
				sprite.scale = Vector3(
					size.x / (tex_size.x * sprite.pixel_size),
					size.x / (tex_size.x * sprite.pixel_size), 1)
			else:
				sprite.scale = Vector3(
					size.x / (tex_size.x * sprite.pixel_size),
					size.y / (tex_size.y * sprite.pixel_size), 1)
		
		sprite.translation = int(sprite_centered) * trans + sprite_translation
		sprite.rotation_degrees = sprite_rotation

func _ready():
	recalculate()
