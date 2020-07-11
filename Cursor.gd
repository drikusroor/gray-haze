extends Node

# Load the custom images for the mouse cursor
var cursors = [load("res://assets/sprites/cursor_default.png"), load("res://assets/sprites/cursor_finger.png"), load("res://assets/sprites/cursor_shoot.png")]

enum CURSOR_TYPES {
	DEFAULT,
	FINGER,
	SHOOT
}

func _ready():
	set_cursor(CURSOR_TYPES.FINGER)
	
func set_cursor(type):
	Input.set_custom_mouse_cursor(cursors[type])
