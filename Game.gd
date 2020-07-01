extends Spatial

var RAY_LENGTH = 444444444444444 #Arbitrarily large ray 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum GAME_STATES { PAUSED, MAIN_MENU, CUTSCENE, PLAYING }
onready var current_player = null
onready var player_container = get_node("/root/Game/PlayerContainer")

# Called when the node enters the scene tree for the first time.
func _ready():
	if player_container:
		var players = player_container.get_children()
		if players.size() > 0:
			var player = players[0]
			current_player = player
			player.select()
			
func set_current_player(player):
	current_player = player
	
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
		
		var collider = selection.collider
		var name = collider.get_name()
		
		if name == "PlayerStaticBody":
			var player = collider.get_parent()
			current_player.deselect()
			current_player = player
			player.select()
			print("select player ", player.get_name())
		
		if name == "GridMap":
			current_player.start_move(selection)
			
	if event.is_action_pressed('ui_focus_next'):
		print('tab')
		var players = player_container.get_children()
		if (players.size() > 0):
			for i in range(players.size()):
				if current_player == players[i]:
					current_player.deselect()
					if players.size() - 1 == i:
						var player = players[0]
						current_player = player
						player.select()		
					else: 
						var player = players[i + 1]
						current_player = player
						player.select()
					break
					
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
	
