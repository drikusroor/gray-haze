extends Spatial

var RAY_LENGTH = 444444444444444 #Arbitrarily large ray 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum GAME_STATES { PAUSED, MAIN_MENU, CUTSCENE, PLAYING }
enum TEAMS { PLAYER, AXIS, CIVILIANS, SPECIAL }
signal select_player(player)
onready var current_team = TEAMS.PLAYER
onready var current_player = null
onready var player_container = get_node("/root/Game/PlayerContainer")
onready var gridmap = get_node("GridMap")

# Called when the node enters the scene tree for the first time.
func _ready():
	gridmap.refresh_astar()
	player_container.init_players()
	next_round()

func end_round():
	pass # insert function body here

func next_round():
	for player in player_container.get_children():
		player.reset_ap()
	set_current_team(TEAMS.PLAYER)
	start_turn()
	
		
func next_turn():
	if current_team == TEAMS.PLAYER:
		set_current_team(TEAMS.AXIS)
	elif current_team == TEAMS.AXIS:
		set_current_team(TEAMS.CIVILIANS)
	elif current_team == TEAMS.CIVILIANS:
		set_current_team(TEAMS.SPECIAL)
	else:
		end_round()
		next_round()
		
	start_turn()
		
func start_turn():
	if current_team == TEAMS.PLAYER:
		# TODO Enable menu
		
		if player_container:
			var players = player_container.get_children()
			if players.size() > 0 and not current_player:
				var player = players[0]
				current_player = player
				player.select()
	else:
		# TODO Disable menu
		pass
		
	if current_team == TEAMS.AXIS:
		start_timer_next_turn()
		
	if current_team == TEAMS.CIVILIANS:
		start_timer_next_turn()
		
	if current_team == TEAMS.SPECIAL:
		start_timer_next_turn()
			
func set_current_team(team):
	current_team = team
			
func set_current_player(player):
	current_player = player
	
func select_player(player):
	if (current_player):
		current_player.deselect()
	set_current_player(player)
	player.select()
	
	emit_signal("select_player", player)
	
func get_objects_under_mouse():
	var camera = get_viewport().get_camera()
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = camera.project_ray_origin(mouse_pos)
	var ray_to = ray_from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	return selection

func _unhandled_input(event):
	if event.is_action_pressed('click'):
		
		var selection = get_objects_under_mouse()
		if (selection.size() == 0):
			return
		
		var collider = selection.collider
		var name = collider.get_name()
		
		if current_team == TEAMS.PLAYER:
			
			if name == "PlayerStaticBody":
				var player = collider.get_parent()
				select_player(player)
				
			if name == "GridMap":
				gridmap.refresh_astar(current_player)
				current_player.start_move(selection)
	
	if event.is_action_pressed('ui_focus_prev'):
		var players = player_container.get_children()
		if (players.size() > 0):
			for i in range(players.size()):
				if current_player == players[i]:
					var prev_player = null
					if i == 0:
						prev_player = players[players.size() - 1]
					else: 
						prev_player = players[i - 1]
					select_player(prev_player)
					break
	elif event.is_action_pressed('ui_focus_next'):
		var players = player_container.get_children()
		if (players.size() > 0):
			for i in range(players.size()):
				if current_player == players[i]:
					var next_player = null
					if players.size() - 1 == i:
						next_player = players[0]
					else: 
						next_player = players[i + 1]
					select_player(next_player)
					break
func start_timer_next_turn():
	_on_timer_next_turn_timeout()

func _on_timer_next_turn_timeout():
	next_turn()
					
func handle_hover():
	var selection = get_objects_under_mouse()
	if (selection.size() == 0):
		return
		
	var collider = selection.collider
	var name = collider.get_name()
	
	if name == "GridMap":
		var gridmap = collider
		gridmap.handle_hover(selection)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	handle_hover()
	
