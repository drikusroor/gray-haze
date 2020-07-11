extends Node


# Declare member variables here. Examples:
onready var game = get_node("/root/Game")
onready var player_container = get_node("/root/Game/PlayerContainer")
onready var enemy_icon_scene = preload("res://EnemyIcon.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	player_container.connect( "players_initialized", self, "_on_players_initialized" )
	player_container.connect( "perception_checked", self, "_on_perception_checked" )
	game.connect( "select_player", self, "_on_select_player" )
	
func _on_players_initialized():
	var enemies = player_container.get_children_of_type(game.PLAYER_TEAMS.ENEMY)
	for enemy in enemies:
		var enemy_icon = enemy_icon_scene.instance()
		enemy_icon.init(self, enemy)
		add_child(enemy_icon)
	
func _on_select_player(player):
	update_perception_sprites()

func _on_perception_checked():
	update_perception_sprites()
		
func update_perception_sprites():
	for enemy_icon in get_children():
		if enemy_icon._player:
			var is_seen = enemy_icon._player.is_seen_by(game.current_player)
			if is_seen:
				enemy_icon.set_sprite(1)
			else:
				enemy_icon.set_sprite(0)
