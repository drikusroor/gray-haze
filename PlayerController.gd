extends Position3D

export(float) var SPEED = 10.0

# Stats
var max_ap = 25
var ap = 25
var max_hp = 25
var hp = 25

enum STATES { IDLE, PLANNING, FOLLOW, SHOOTING }
enum WALKING_SPEED { SNEAK, WALK, RUN }
export(bool) var selected = false

var player_type
var player_team
var enemy_team
var _state

var sees = []
var is_seen_by = []

var path = []
var target_point_world = Vector3()
var target_translation

var velocity = Vector3()

signal player_updated(player)

# Scenes
onready var waypoint_correct_scene = preload("res://Waypoint.tscn")
onready var waypoint_container = get_node("/root/Game/GridMap/WaypointContainer")

# Textures
var player_textures = [load("res://assets/sprites/allied.png"), load("res://assets/sprites/allied_selected.png")]
var enemy_textures = [load("res://assets/sprites/axis.png")]

# HOC components
onready var game = get_node("/root/Game")
onready var gridmap = get_node("/root/Game/GridMap")
onready var player_container = get_parent()

# Children
onready var player_sprite = get_node("PlayerSprite")
onready var player_audio = get_node("PlayerAudio")
onready var player_icon_pos = get_node("PlayerIconPosition")

var _name = ""

func _ready():
	_change_state(STATES.IDLE)
	game.connect( "start_turn", self, "_on_start_turn" )
	
	if player_team == game.PLAYER_TEAMS.PLAYER:
		enemy_team = game.PLAYER_TEAMS.ENEMY
		set_sprite(0)
	elif player_team == game.PLAYER_TEAMS.ENEMY:
		enemy_team = game.PLAYER_TEAMS.PLAYER
		set_sprite(0)
	else:
		enemy_team = game.PLAYER_TEAMS.ENEMY
		set_sprite(0)
	
func init_player(position, data):
	_name = data.name
	max_hp = data.max_hp
	player_type = data.type
	player_team = data.team	
	reset_ap()
	reset_hp()
	translation = position

func set_sprite(new_type):
	var _type = new_type
	if player_team == game.PLAYER_TEAMS.PLAYER:
		player_sprite.texture = player_textures[new_type]
	else:
		player_sprite.texture = enemy_textures[new_type]

func reset_ap():
	ap = max_ap
	emit_signal("player_updated")
	
func reset_hp():
	hp = max_hp
	emit_signal("player_updated")
	
func _on_start_turn(team):
	if team == game.PLAYER_TEAMS.PLAYER and player_team == team and path.size() > 0:
		gridmap.refresh_astar(self)
		path = gridmap.find_path(translation, target_translation)
		draw_waypoints()

func deselect():
	set_sprite(0)
	if selected:
		selected = false
	emit_signal("player_updated")
		
func select():
	set_sprite(1)
	if not selected:
		selected = true
		
	if _state == STATES.PLANNING:
		gridmap.refresh_astar(self)
		path = gridmap.find_path(translation, target_translation)
		draw_waypoints()
		
	emit_signal("player_updated")
	
func get_grid_pos():
	return gridmap.world_to_grid(translation)
		
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
		
	elif new_state == STATES.IDLE:
		if player_type == game.PLAYER_TYPES.NPC:
			# do next player in team
			pass
		
	if new_state != STATES.FOLLOW:
		player_audio.stop()
		
	_state = new_state
	emit_signal("player_updated")

func _process_player(_delta):
	if not _state == STATES.FOLLOW:
		return
		
	if ap < 2:
		_change_state(STATES.PLANNING)
		return
		
	var arrived_to_next_point = move_to(target_point_world)
	if arrived_to_next_point:
		
		ap -= 2
		emit_signal("player_updated")
		player_container.perception_check()
		waypoint_container.remove_waypoint(self, path[0])
				
		var next_point = path[0]
		path.remove(0)
		if len(path) == 0:
			waypoint_container.remove_owner_waypoints(self)
			translation = next_point
			_change_state(STATES.IDLE)
			return
		
		target_point_world = path[0]

func _process_npc(_delta):
	
	if not _state == STATES.FOLLOW or _state == STATES.SHOOTING:
		return
	
	if ap < 2:
		_change_state(STATES.PLANNING)
		switch_to_next_colleague()
		return
		
	if _state == STATES.FOLLOW:
		var arrived_to_next_point = move_to(target_point_world)
		if arrived_to_next_point:
			
			ap -= 2
			emit_signal("player_updated")
			player_container.perception_check()
			waypoint_container.remove_waypoint(self, path[0])
					
			var next_point = path[0]
			path.remove(0)
			if len(path) == 0:
				waypoint_container.remove_owner_waypoints(self)
				translation = next_point
				_change_state(STATES.IDLE)
				switch_to_next_colleague()
				return
			
			target_point_world = path[0]

func _process(_delta):
	var camera_pos = get_viewport().get_camera().global_transform.origin
	camera_pos.y = 0
	player_sprite.look_at(camera_pos, Vector3(0, 1, 0))
	
	if (player_type == game.PLAYER_TYPES.NPC):
		_process_npc(_delta)
	elif (player_type == game.PLAYER_TYPES.PLAYER):
		_process_player(_delta)
	
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

func do_turn_actions():
	waypoint_container.remove_owner_waypoints(self)
	gridmap.refresh_astar(self)
	var enemies = player_container.get_visible_children_of_team(player_team, enemy_team)

#	if enemies.size() == 0:
#		enemies = get_most_recent_sightings(enemy_team)
	
	if enemies.size() > 0:
		var closest_enemy = enemies[0]
		var shortest_path = []
		
		for enemy in enemies:
			var enemy_grid_pos = gridmap.world_to_grid(enemy.translation)
			var adjacent_tiles = gridmap.get_adjacent_tiles(enemy_grid_pos)
			var enemy_path = []
			for adjacent_tile in adjacent_tiles:
				if enemy_path:
					break
				else:
					var path = gridmap.find_path(self.translation, gridmap.grid_to_world(adjacent_tile))
					if path.size() > 0:
						enemy_path = path
			if !shortest_path or enemy_path.size() < shortest_path.size():
				shortest_path = enemy_path
				closest_enemy = enemy
				
		if shortest_path.size() > 0:
			path = shortest_path
			target_translation = shortest_path[shortest_path.size() - 1]
			draw_waypoints()
			_change_state(STATES.FOLLOW)
			
		
	else:
		# Walk to random spot in map
		game.next_turn()

func switch_to_next_colleague():
	var colleagues = player_container.get_children_of_team(player_team)
	for c_idx in range(colleagues.size()):
		var colleague = colleagues[c_idx]
		if colleague == self:
			if c_idx == colleagues.size() - 1:
				game.next_turn()
			else:
				var next_colleague = colleagues[c_idx + 1]
				next_colleague.do_turn_actions()		

func attack(enemy):
	pass
	
func handle_enemy_hover(current_player):
	pass

func is_seen_by(player):
	var is_seen = false
	for enemy in is_seen_by:
		if player == enemy:
			is_seen = true
	return is_seen

func sees(player):
	var sees_player = false
	for enemy in sees:
		if player == enemy:
			sees_player = true
	return sees_player
