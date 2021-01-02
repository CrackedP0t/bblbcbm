extends Spatial

class_name Room

export(NodePath) var outer_wall = null
export(Rect2) var rect = Rect2(0, 0, 1, 1)
export(Array, NodePath) var avoid_fading = []

onready var parent = get_parent()
onready var world = get_node("/root/Main/WorldEnvironment")
onready var location = is_in_group("Locations")

var animation_player = AnimationPlayer.new()
var entered = false
var to_fade = []
var rooms = []

func get_rect():
	var r = rect
	r.position += Vector2(global_transform.origin.x, global_transform.origin.z)
	return r

func _ready():
	for i in len(avoid_fading):
		avoid_fading[i] = get_node(avoid_fading[i]).get_node("Fader")
	for child in get_children():
		if child.is_in_group("Rooms"):
			rooms.append(child)
			continue
		var fader = child.get_node_or_null("Fader")
		if fader:
			to_fade.append(fader)
	
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

func fade_in(except=null, avoid=[]):
	if location:
		world.lighten()
	for fader in to_fade:
		if not (fader in avoid):
			fader.fade_in()
	for room in rooms:
		if room != except:
			room.fade_in()
		
func fade_out(except=null, avoid=[]):
	if location:
		world.darken()
	for fader in to_fade:
		if not (fader in avoid):
			fader.fade_out()
	for room in rooms:
		if room != except:
			room.fade_out()

func enter():
	if not entered:
		parent.fade_out(self, avoid_fading)
		if outer_wall:
			animation_player.play("Open")
	entered = true

func exit():
	if entered:
		parent.fade_in(self, avoid_fading)
		if outer_wall:
			animation_player.play("Close")
	entered = false
