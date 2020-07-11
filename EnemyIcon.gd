extends Sprite


# Declare member variables here. Examples:
var _parent = null
var _player = null

# Textures
onready var camera = get_node("/root/Game/Camera")
var icon_textures = [load("res://assets/sprites/enemy_invisible_icon.png"), load("res://assets/sprites/enemy_visible_icon.png")]

# Called when the node enters the scene tree for the first time.
func _ready():
	texture = icon_textures[0]
	pass # Replace with function body.

func set_sprite(new_type):
	texture = icon_textures[new_type]

func init(parent, player):
	_parent = parent
	_player = player
	_player.connect( "player_updated", self, "_on_player_updated" )

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _player and _player.player_icon_pos:
		var camera_pos = camera.unproject_position(_player.player_icon_pos.global_transform.origin)
		position = camera_pos
