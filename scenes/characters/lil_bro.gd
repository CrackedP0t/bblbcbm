extends Spatial

var speed = 3
var acceleration = 6.0

var velocity = 0.0
var close = false
var direction = "Right"

onready var body = $CharacterPlane
onready var big_bro = get_node("/root/Main/BigBro/CharacterPlane")
onready var state_machine = $AnimationTree.get("parameters/playback")

func _on_Area_area_entered(_area):
	close = true

func _on_Area_area_exited(_area):
	close = false

func _physics_process(_delta):
	var movement = body.global_transform.origin.direction_to(big_bro.global_transform.origin)
	
	if movement.x > 0:
		direction = "Right"
	else:
		direction = "Left"
	
	if close:
		velocity = max(velocity - acceleration, 0)
		state_machine.travel("Idle " + direction)
	else:
		velocity = min(velocity + acceleration, speed)
		state_machine.travel("Walk " + direction)
		
	body.move_and_slide(movement * velocity)

func _ready():
	state_machine.start("Idle Right")
