extends Camera


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func move(x, y):
	var MASS = 1.0
	var ARRIVE_DISTANCE = 0.1
	
	var desired_velocity = Vector3(x, y, 0)
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	translation += velocity * get_process_delta_time()

func _unhandled_input(event):
	if event.is_action_pressed('ui_up'):
		pass
	elif event.is_action_pressed('ui_down'):
		pass
	
	if event.is_action_pressed('ui_left'):
		pass
	elif event.is_action_pressed('ui_right'):
		pass
