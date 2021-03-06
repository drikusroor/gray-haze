extends Node


# Declare member variables here. Examples:
onready var player_scene = preload("res://Player.tscn")
onready var game = get_node("/root/Game")
onready var gridmap = get_node("/root/Game/GridMap")
signal players_initialized()
signal perception_checked()
onready var initial_players = [
	{"name": "Drikus", "max_ap": 20, "max_hp": 20, "type": game.PLAYER_TYPES.PLAYER, "team": game.PLAYER_TEAMS.PLAYER },
	{"name": "Adriana", "max_ap": 20, "max_hp": 20, "type": game.PLAYER_TYPES.PLAYER, "team": game.PLAYER_TEAMS.PLAYER },
	{"name": "Robert", "max_ap": 20, "max_hp": 20, "type": game.PLAYER_TYPES.PLAYER, "team": game.PLAYER_TEAMS.PLAYER },
	{"name": "Franz", "max_ap": 20, "max_hp": 20, "type": game.PLAYER_TYPES.NPC, "team": game.PLAYER_TEAMS.ENEMY },
	{"name": "Joachim", "max_ap": 20, "max_hp": 20, "type": game.PLAYER_TYPES.NPC, "team": game.PLAYER_TEAMS.ENEMY },
	{"name": "Heinrich", "max_ap": 20, "max_hp": 20, "type": game.PLAYER_TYPES.NPC, "team": game.PLAYER_TEAMS.ENEMY },
]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init_players():
	var cells = gridmap.get_used_cells()
	for p_data in initial_players:
		var player = player_scene.instance()
		for cell_i in range(cells.size()):
			var spawn_cell = cells[cell_i]
			if p_data.type == game.PLAYER_TEAMS.ENEMY:
				spawn_cell = cells[cells.size() - cell_i - 55]
			var cell_id = gridmap.get_cell_item(spawn_cell.x, spawn_cell.y, spawn_cell.z)
			var world_position = gridmap.grid_to_world(spawn_cell)
			var valid_position = true
			if (cell_id == 1):
				valid_position = false
			for existing_player in get_children():
				if existing_player.translation == world_position:
					valid_position = false
			
			if valid_position:
				player.init_player(world_position, p_data)
				add_child(player)
				break
			
	emit_signal("players_initialized")

func get_children_of_type(type):
	var players_of_type = []
	for player in get_children():
		if player.player_type == type:
			players_of_type.append(player)

	return players_of_type
	
func get_children_of_team(team):
	var players_of_type = []
	for player in get_children():
		if player.player_team == team:
			players_of_type.append(player)

	return players_of_type
	
func get_visible_children_of_team(client_team, target_team):
	# TODO Add functionality to only return players that are
	# visible for the team in question
	return get_children_of_team(target_team)
	
func perception_check():
	for player in get_children():
		var sees = []
		var is_seen_by = []
		for other in get_children():
			if other == player:
				pass
			else:
				var distance = player.translation.distance_to(other.translation)
				if distance < 25:
					sees.append(other)
					is_seen_by.append(other)
		player.sees = sees
		player.is_seen_by = is_seen_by
		
	emit_signal("perception_checked")
	
