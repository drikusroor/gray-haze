extends Spatial

onready var sprite = get_node("Sprite3D")
#onready var text = get_node("Sprite3D/WaypointText")
var textures = [load("res://assets/sprites/waypoint.png"), load("res://assets/sprites/waypoint-invalid.png")]
var _owner = null
var _type = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func init(new_owner, sprite_type):
	set_owner(new_owner)
	
func set_owner(new_owner):
	_owner = new_owner
	
func get_owner():
	return _owner

func set_type(new_type):
	var _type = new_type
	sprite.texture = textures[new_type]
	
func set_number(ap):
	if ap < 0:
		pass
#	else:
#		text.add_text(str(ap))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
