extends Spatial

var speed = 3
var gravity = Vector3(0, 0, 0)

var direction = "Right"
var velocity = Vector3()
var interact = null
var inside = null

onready var state_machine = $AnimationTree.get("parameters/playback")
onready var body = $CharacterPlane
onready var camera = get_viewport().get_camera()
onready var world = get_node("/root/Main/WorldEnvironment")

# Called when the node enters the scene tree for the first time.
func _ready():
	state_machine.start("Idle Right")

func _physics_process(_delta):
	interact = null
	var interacts = $CharacterPlane/Interact.get_overlapping_bodies()
	var close_dist = INF
	for i in interacts:
		var dist = body.translation.distance_to(i.global_transform.origin)
		if dist < close_dist:
			close_dist = dist
			interact = i.get_parent()
			
	if Input.is_action_just_pressed("interact"):
		if interact:
			interact.interact(body.transform)
	
	var movement = Vector3()
	
	if Input.is_action_pressed("up"):
		movement.z -= speed
	if Input.is_action_pressed("down"):
		movement.z += speed
	if Input.is_action_pressed("left"):
		direction = "Left"
		movement.x -= speed
	if Input.is_action_pressed("right"):
		direction = "Right"
		movement.x += speed
		
	if movement == Vector3():
		state_machine.travel("Idle " + direction)
	else:
		state_machine.travel("Walk " + direction)
	
	movement += gravity
	
	body.move_and_slide(movement, -gravity.normalized())

	camera.update_position(body.global_transform.origin)
	
	var point = Vector2(body.global_transform.origin.x, body.global_transform.origin.z)
	var cont = false
	
	for building in get_tree().get_nodes_in_group("Buildings"):
		cont = building.get_rect().has_point(point)
		if cont:
			if not inside:
				building.enter()
				world.darken()
				inside = building
			elif inside != building:
				inside.exit()
				building.enter()
				inside = building
			break
	
	if not cont and inside:
		inside.exit()
		world.lighten()
		inside = null
		
	if inside:
		inside.check_rooms(point)
