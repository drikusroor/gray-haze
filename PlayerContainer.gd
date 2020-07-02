extends Node


# Declare member variables here. Examples:
onready var player_scene = preload("res://Player.tscn")
onready var game = get_node("/root/Game")
onready var gridmap = get_node("/root/Game/GridMap")
var initial_players = ["Drikus", "Adriana", "Robert", "Peter", "Vladimir", "Mark R.",
"Addy","Adel","Adela","Adelaida","Adelaide","Adele","Adelheid","Adelice","Adelina",
"Adelind","Adeline","Adella","Adelle","Adena","Adey","Joey", "SHarif"]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init_players():
	var cells = gridmap.get_used_cells()
	for p in initial_players:
		var player = player_scene.instance()
		for cell_i in range(cells.size()):
			var spawn_cell = cells[cell_i]
			var cell_id = gridmap.get_cell_item(spawn_cell.x, spawn_cell.y, spawn_cell.z)
			var world_position = gridmap.grid_to_world(spawn_cell)
			var valid_position = true
			if (cell_id == 1):
				valid_position = false
			for existing_player in get_children():
				if existing_player.translation == world_position:
					valid_position = false
			
			if valid_position:
				player.init_player(world_position)
				add_child(player)
				break
				
			
			
	
	var players = get_children()
		
