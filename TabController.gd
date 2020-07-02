extends TabContainer


# Declare member variables here. Examples:
onready var game = get_node("/root/Game")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_TabContainer_tab_changed(tab):
	print("Tab: ", game.current_player)
	pass # Replace with function body.


func _on_UI_select_player(player):
	print("TabContainer reads you loud and clear ", player)
