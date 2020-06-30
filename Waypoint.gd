extends Sprite3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var _owner = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(new_owner):
	set_owner(new_owner)

func set_owner(new_owner):
	_owner = new_owner
	
func get_owner():
	return _owner

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
