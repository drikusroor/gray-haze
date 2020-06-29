extends Position3D

export(float) var SPEED = 10.0
var RAY_LENGTH = 444444444444444 #Arbitrarily large ray 

enum STATES { IDLE, FOLLOW }
var _state = null

var path = []
var target_point_world = Vector3()
var target_translation = Vector3()

var velocity = Vector3()

func _ready():
	_change_state(STATES.IDLE)


func _change_state(new_state):
	if new_state == STATES.FOLLOW:
		path = get_parent().get_node('GridMap').find_path(translation, target_translation)
		if not path or len(path) == 1:
			_change_state(STATES.IDLE)
			return
		# The index 0 is the starting cell
		# we don't want the character to move back to it in this example
		target_point_world = path[1]
	_state = new_state

func _process(delta):
	
	var camera_pos = get_viewport().get_camera().global_transform.origin
	camera_pos.y = 0
	look_at(camera_pos, Vector3(0, 1, 0))
	
	if not _state == STATES.FOLLOW:
		return
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
		path.remove(0)
		if len(path) == 0:
#			translation.x = round(translation.x / 32.0) * 32
#			translation.y = round(translation.y / 32.0) * 32
#			rotation.y = stepify(rotation.y, PI/2)
			_change_state(STATES.IDLE)
			return
		target_point_world = path[0]


func move_to(world_position):
	var MASS = 1.0
	var ARRIVE_DISTANCE = 0.1
	
	var desired_velocity = (world_position - translation).normalized() * SPEED
	var steering = desired_velocity - velocity
	velocity += steering / MASS
	translation += velocity * get_process_delta_time()
#	rotation = velocity.angle()
	return translation.distance_to(world_position) < ARRIVE_DISTANCE
	
func get_objects_under_mouse():
	var camera = get_viewport().get_camera()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	return selection

func _input(event):
	if event.is_action_pressed('click'):
		
		var selection = get_objects_under_mouse()
		if (selection.size() == 0):
			print('No hit')
			return
		var position3D = selection.position
		print('Click target', position3D)

		target_translation = position3D
		_change_state(STATES.FOLLOW)
	
