extends Spatial

var speed = 3
var gravity = Vector3(0, 0, 0)

var direction = "Right"
var velocity = Vector3()
var interact = null
var inside = []

onready var state_machine = $AnimationTree.get("parameters/playback")
onready var body = $CharacterPlane
onready var camera = get_viewport().get_camera()

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
	
	for room in get_tree().get_nodes_in_group("Rooms"):
		cont = room.get_rect().has_point(point)
		if cont:
			room.enter()
		else:
			room.exit()
