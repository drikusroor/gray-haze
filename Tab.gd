extends Tabs

onready var name_text = get_node("PlayerName")
onready var ap_text = get_node("AP")
onready var hp_text = get_node("HP")
onready var state_text = get_node("STATE")
onready var selected = get_node("SELECTED")
var _parent = null
var _player = null

# Called when the node enters the scene tree for the first time.
func _ready():
	update_tab_data()

func init(parent, player):
	_parent = parent
	_player = player
	_player.connect( "player_updated", self, "_on_player_updated" )

func update_tab_data():
	name_text.text = _player._name
	ap_text.text = str(_player.ap)
	hp_text.text = str(_player.hp)
	state_text.text = str(_player._state)
	selected.text = str(_player.selected)	

func _on_player_updated():
	update_tab_data()
