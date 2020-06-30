extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func reset_waypoints():
	for child in get_children():
		child.queue_free()
		
func remove_owner_waypoints(owner):
	for child in get_children():
		if child._owner == owner:
			child.queue_free()
		
func remove_waypoint(owner, position):
	for child in get_children():
			if child.translation == position and child._owner == owner:
				child.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
