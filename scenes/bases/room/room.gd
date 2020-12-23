extends Spatial

class_name Room

export(NodePath) var outer_wall = null
export(Rect2) var rect = Rect2(0, 0, 1, 1)
export(Array, NodePath) var avoid_fading = []

var animation_player = AnimationPlayer.new()
var entered = false
var to_fade

func get_rect():
	var r = rect
	r.position += Vector2(global_transform.origin.x, global_transform.origin.z)
	return r

func _ready():
	if outer_wall:
		var open = Animation.new()
		open.length = 0.5
		var open_track = open.add_track(Animation.TYPE_VALUE)
		open.track_set_path(open_track, String(outer_wall) + ":mesh_translation:y")
		open.track_insert_key(open_track, 0.0, 0.0)
		open.track_insert_key(open_track, 0.5, 5.0)
		open.track_set_interpolation_type(open_track, Animation.INTERPOLATION_CUBIC)
		animation_player.add_animation("Open", open)
		
		var close = Animation.new()
		close.length = 0.5
		var close_track = close.add_track(Animation.TYPE_VALUE)
		close.track_set_path(close_track, String(outer_wall) + ":mesh_translation:y")
		close.track_insert_key(close_track, 0.0, 5.0)
		close.track_insert_key(close_track, 0.5, 0.0)
		close.track_set_interpolation_type(close_track, Animation.INTERPOLATION_CUBIC)
		animation_player.add_animation("Close", close)
		
		add_child(animation_player)

func enter():
	for plane in to_fade:
		var avoid = false
		for avoid_plane in avoid_fading:
			if get_node(avoid_plane) == plane:
				avoid = true
				break
		if not avoid and plane.get_parent() != self:
			plane.fade_out()
	if outer_wall:
		animation_player.play("Open")

func exit():
	for plane in to_fade:
		var avoid = false
		for avoid_plane in avoid_fading:
			if get_node(avoid_plane) == plane:
				avoid = true
				break
		if not avoid and plane.get_parent() != self:
			plane.fade_in()
	if outer_wall:
		animation_player.play("Close")
