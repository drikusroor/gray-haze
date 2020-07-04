extends TabContainer

# Declare member variables here. Examples:
onready var game = get_node("/root/Game")
onready var player_container = get_node("/root/Game/PlayerContainer")
onready var tab_scene = preload("res://Tab.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	player_container.connect( "players_initialized", self, "_on_players_initialized" )
	game.connect( "select_player", self, "_on_select_player" )

func _on_TabContainer_tab_changed(i):
	var tab = get_children()[i]
	if (tab._player != game.current_player):
		game.select_player(tab._player)

func _on_players_initialized():
	var players = player_container.get_children()
	for i in range(players.size()):
		var tab = tab_scene.instance()
		var player = players[i]
		tab.init(self, player)
		add_child(tab)
		set_tab_title(i, player._name)
		
func _on_select_player(player):
	for i in range(get_children().size()):
		var tab = get_children()[i]
		if (player == tab._player):
			set_current_tab(i)
			tab.update_tab_data()
			break
