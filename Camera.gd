extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity = Vector3()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var x = 0
	var z = 0
	
	if Input.is_action_pressed('ui_up'):
		z = 1
	elif Input.is_action_pressed('ui_down'):
		z = -1
		
	if Input.is_action_pressed('ui_left'):
		x = 1
	elif Input.is_action_pressed('ui_right'):
		x = -1
		
	var move_vector = Vector3(x, 0, z)
	
	if Input.is_action_pressed('shift'):
		move_vector *= 3
	
	move(move_vector)

func move(move_vector):
	var MASS = 10.0
	var SPEED = 10
	var desired_velocity = move_vector.rotated(Vector3(0, 45, 0).normalized(), PI / 4) * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	translation += velocity * get_process_delta_time()

#func _unhandled_input(event):
#
#
#	if event.is_action('ui_up'):
#		z = 1
#	elif event.is_action('ui_down'):
#		z = -1
#	else: 
#		z= 0
#
#	if event.is_action('ui_left'):
#		x = 1
#	elif event.is_action('ui_right'):
#		x = -1
#	else:
#		x = 0
		
