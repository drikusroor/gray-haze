extends Node


# Declare member variables here. Examples:
onready var game = get_node("/root/Game")
onready var player_container = get_node("/root/Game/PlayerContainer")
onready var enemy_icon_scene = preload("res://EnemyIcon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	player_container.connect( "players_initialized", self, "_on_players_initialized" )
	game.connect( "select_player", self, "_on_select_player" )
	
func _on_players_initialized():
	var enemies = player_container.get_children_of_type(game.PLAYER_TEAMS.ENEMY)
	for i in range(enemies.size()):
		var enemy_icon = enemy_icon_scene.instance()
		var enemy = enemies[i]
		enemy_icon.init(self, enemy)
		add_child(enemy_icon)
	
func _on_select_player():
	pass
