extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal select_player(player)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Game_select_player(player):
	emit_signal("select_player", player)
