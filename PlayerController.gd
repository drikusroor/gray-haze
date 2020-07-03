extends Position3D

export(float) var SPEED = 10.0

# Stats
var max_ap = 20
var ap = 20
var max_hp = 20
var hp = 20

enum PLAYER_TYPES { PLAYER, NPC }
enum PLAYER_TEAMS { ALLIES, AXIS, CIVILIANS }
enum STATES { IDLE, PLANNING, FOLLOW }
enum WALKING_SPEED { SNEAK, WALK, RUN }
export(bool) var selected = false

var _player_type = PLAYER_TYPES.PLAYER
var _player_team = PLAYER_TEAMS.ALLIES
var _state = null

var path = []
var target_point_world = Vector3()
var target_translation = Vector3()

var velocity = Vector3()

onready var waypoint_correct_scene = preload("res://WaypointCorrect.tscn")
onready var waypoint_incorrect_scene = preload("res://WaypointIncorrect.tscn")
onready var waypoint_container = get_node("/root/Game/GridMap/WaypointContainer")
onready var game = get_node("/root/Game")
onready var gridmap = get_node("/root/Game/GridMap")
onready var player_sprite = get_node("PlayerSprite")
onready var player_audio = get_node("PlayerAudio")

var _name = ""

func _ready():
	_change_state(STATES.IDLE)
	
func init_player(position, data):
	_name = data.name
	reset_ap()
	reset_hp()
	translation = position
	
func reset_ap():
	ap = max_ap
	
func reset_hp():
	hp = max_hp

func deselect():
	player_sprite.opacity = 0.5
	if selected:
		selected = false
		
func select():
	player_sprite.opacity = 1
	if not selected:
		selected = true

func _change_state(new_state):
	if new_state == STATES.PLANNING:
		path = gridmap.find_path(translation, target_translation)
		for node in path:
			var ap_left = ap
			var waypoint = waypoint_correct_scene.instance()
			waypoint.init(self)
			var waypoint_pos = node
			waypoint.translation = waypoint_pos
			waypoint.modulate.a = 0.3
			waypoint_container.add_child(waypoint)
			
	elif new_state == STATES.FOLLOW:
		if not path or len(path) == 1:
			_change_state(STATES.IDLE)
			return
		# The index 0 is the starting cell
		# we don't want the character to move back to it in this example
		player_audio.play()
		
		for node in path:
			var waypoint = waypoint_correct_scene.instance()
			waypoint.init(self)
			var waypoint_pos = node
			waypoint.translation = waypoint_pos
			waypoint.modulate.a = 0.3
			waypoint_container.add_child(waypoint)
		
		target_point_world = path[1]
	if new_state == STATES.IDLE:
		player_audio.stop()
		
	_state = new_state

func _process(delta):
	
	var camera_pos = get_viewport().get_camera().global_transform.origin
	camera_pos.y = 0
	look_at(camera_pos, Vector3(0, 1, 0))
	
	if not _state == STATES.FOLLOW:
		return
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
		waypoint_container.remove_waypoint(self, path[0])
		var next_point = path[0]
		path.remove(0)
		if len(path) == 0:
			waypoint_container.remove_owner_waypoints(self)
			translation = next_point
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
	return translation.distance_to(world_position) < ARRIVE_DISTANCE
	
func start_move(selection):
	var position3D = selection.position
	var gridmap_position = gridmap.world_to_grid(position3D)
	var target_translation_gridmap_position = gridmap.world_to_grid(target_translation)
	
	waypoint_container.remove_owner_waypoints(self)
	if gridmap_position == target_translation_gridmap_position:
		_change_state(STATES.FOLLOW)
	else:
		target_translation = position3D
		_change_state(STATES.PLANNING)
		
		
	
