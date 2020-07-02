extends Tabs


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _parent = null
var _player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(parent, player):
	_parent = parent
	_player = player
