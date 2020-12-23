extends Spatial

export(NodePath) var outer_wall = null
export(Rect2) var rect = Rect2(0, 0, 1, 1)

onready var parent = get_parent()

var animation_player = AnimationPlayer.new()
var entered = false
var rooms = []
var inside
var to_fade = []
var room_fade = []

func get_rect():
	var r = rect
	r.position += Vector2(parent.global_transform.origin.x, parent.global_transform.origin.z)
	return r

func _ready():
	for plane in get_tree().get_nodes_in_group("Fadable"):
		var plane_parent = plane.get_parent()
		if plane_parent != self and plane_parent.get_parent() != self:
			to_fade.append(plane)
		elif plane_parent == self or plane_parent.get_parent() == self:
			room_fade.append(plane)
	
	for n in self.get_children():
		if n is Room:
			n.to_fade = room_fade
			rooms.append(n)
	
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
		plane.fade_out()
		
	if outer_wall:
		animation_player.play("Open")

func exit():
	for plane in to_fade:
		plane.fade_in()
		
	if outer_wall:
		animation_player.play("Close")
		
func check_rooms(point):
	var cont = false
	
	for room in rooms:
		cont = room.get_rect().has_point(point)
		if cont:
			if not inside:
				room.enter()
				inside = room
			elif inside != room:
				inside.exit()
				room.enter()
				inside = room
			break
	
	if not cont and inside:
		inside.exit()
		inside = null
	
