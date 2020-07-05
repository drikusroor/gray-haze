extends Position3D

export(float) var SPEED = 10.0

# Stats
var max_ap = 25
var ap = 25
var max_hp = 25
var hp = 25

enum PLAYER_TYPES { PLAYER, NPC }
enum PLAYER_TEAMS { ALLIES, AXIS, CIVILIANS }
enum STATES { IDLE, PLANNING, FOLLOW }
enum WALKING_SPEED { SNEAK, WALK, RUN }
export(bool) var selected = false

var _player_type = PLAYER_TYPES.PLAYER
var _player_team = PLAYER_TEAMS.ALLIES
var _state

var path = []
var target_point_world = Vector3()
var target_translation

var velocity = Vector3()

signal player_updated(player)

# Scenes
onready var waypoint_correct_scene = preload("res://Waypoint.tscn")
onready var waypoint_container = get_node("/root/Game/GridMap/WaypointContainer")

# HOC components
onready var game = get_node("/root/Game")
onready var gridmap = get_node("/root/Game/GridMap")

# Children
onready var player_sprite = get_node("PlayerSprite")
onready var player_audio = get_node("PlayerAudio")

var _name = ""

func _ready():
	_change_state(STATES.IDLE)
	game.connect( "start_turn", self, "_on_start_turn" )
	
func init_player(position, data):
	_name = data.name
	reset_ap()
	reset_hp()
	translation = position
	
func reset_ap():
	ap = max_ap
	emit_signal("player_updated")
	
func reset_hp():
	hp = max_hp
	emit_signal("player_updated")
	
func _on_start_turn(team):
	if team == game.TEAMS.PLAYER and path.size() > 0:
		gridmap.refresh_astar(self)
		path = gridmap.find_path(translation, target_translation)
		draw_waypoints()

func deselect():
	player_sprite.opacity = 0.6
	if selected:
		selected = false
	emit_signal("player_updated")
		
func select():
	player_sprite.opacity = 1
	if not selected:
		selected = true
		
	if _state == STATES.PLANNING:
		gridmap.refresh_astar(self)
		path = gridmap.find_path(translation, target_translation)
		draw_waypoints()
		
	emit_signal("player_updated")
		
func draw_waypoints():
	waypoint_container.remove_owner_waypoints(self)
	var ap_left = ap
	for node_i in range(path.size()):
		var node = path[node_i]
		var waypoint = waypoint_correct_scene.instance()
		waypoint.init(self, 0)
		var waypoint_pos = node
		waypoint.translation = waypoint_pos
		waypoint_container.add_child(waypoint)
		waypoint.sprite.modulate.a = 0.5
		
		if node_i == path.size() - 1:
			waypoint.target = true
			waypoint.sprite.scale = Vector3(2, 2, 0)
		
		ap_left -= 2
		
		if ap_left < 0:
			waypoint.set_type(1)

func _change_state(new_state):
	if new_state == STATES.PLANNING:
		path = gridmap.find_path(translation, target_translation)
		draw_waypoints()
			
	elif new_state == STATES.FOLLOW:
		if not path or len(path) == 0:
			_change_state(STATES.IDLE)
			return
		# The index 0 is the starting cell
		# we don't want the character to move back to it in this example
		player_audio.play()
		draw_waypoints()
		target_point_world = path[0]
		
	if new_state != STATES.FOLLOW:
		player_audio.stop()
		
	_state = new_state
	emit_signal("player_updated")

func _process(_delta):
	var camera_pos = get_viewport().get_camera().global_transform.origin
	camera_pos.y = 0
	look_at(camera_pos, Vector3(0, 1, 0))
	
	if not _state == STATES.FOLLOW:
		return
		
	if ap < 2:
		_change_state(STATES.PLANNING)
		return
		
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
		
		ap -= 2
		emit_signal("player_updated")
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
	var target_translation_gridmap_position
	if target_translation:
		target_translation_gridmap_position = gridmap.world_to_grid(target_translation)
	
	waypoint_container.remove_owner_waypoints(self)
	if gridmap_position == target_translation_gridmap_position:
		_change_state(STATES.FOLLOW)
	else:
		target_translation = position3D
		_change_state(STATES.PLANNING)
		
func _unhandled_input(event):
	if event.is_action_pressed('ui_cancel'):
		if _state == STATES.PLANNING and selected:
			target_translation = null
			waypoint_container.remove_owner_waypoints(self)
			_change_state(STATES.IDLE)
