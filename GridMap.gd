extends GridMap

func get_used_cells_by_id(id : int):
	var arr = []
	var tiles = get_used_cells()
	for i in tiles:
		if(get_cell_item(i.x, i.y, i.z) == id):
			arr.append(i)
	return arr

# You can only create an AStar node from code, not from the Scene tab
onready var astar_node = AStar.new()
# The Tilemap node doesn't have clear bounds so we're defining the map's limits here
export(Vector3) var map_size = Vector3(9, 1, 9)

# The path start and end variables use setter methods
# You can find them at the bottom of the script
var path_start_position = Vector3() setget _set_path_start_position
var path_end_position = Vector3() setget _set_path_end_position

var _point_path = []

const BASE_LINE_WIDTH = 3.0
const DRAW_COLOR = Color('#fff')

# get_used_cells_by_id is a method from the TileMap node
# here the id 0 corresponds to the grey tile, the obstacles
var real_cell_size = cell_size
onready var obstacles = get_used_cells_by_id(1)
onready var _half_cell_size = real_cell_size / 2

func _ready():
	pass	

func init_gridmap():
	var walkable_cells_list = astar_add_walkable_cells(obstacles)
	astar_connect_walkable_cells(walkable_cells_list)

func find_cell_by_vector(vector):
	vector = world_to_grid(vector)
	var found = null
	for cell in get_used_cells():
		if cell == vector:
			return cell
		
# Loops through all cells within the map's bounds and
# adds all points to the astar_node, except the obstacles
func astar_add_walkable_cells(obstacles = []):
	var points_array = []
	var cells = get_used_cells()
	
	for i in range(cells.size()):
		var c = cells[i]
		var type = get_cell_item(c.x, c.y, c.z)
		var point = c
		if type == 1:
			continue
			
		points_array.append(point)
		# The AStar class references points with indices
		# Using a function to calculate the index from a point's coordinates
		# ensures we always get the same index with the same input point
#		var point_index = calculate_point_index(point)
		var point_index = i
		# AStar works for both 2d and 3d, so we have to convert the point
		# coordinates from and to Vector3s
		astar_node.add_point(point_index, Vector3(point.x, point.y, point.z))		
			
	return points_array


# Once you added all points to the AStar node, you've got to connect them
# The points don't have to be on a grid: you can use this class
# to create walkable graphs however you'd like
# It's a little harder to code at first, but works for 2d, 3d,
# orthogonal grids, hex grids, tower defense games...
func astar_connect_walkable_cells(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		# For every cell in the map, we check the one to the top, right.
		# left and bottom of it. If it's in the map and not an obstalce,
		# We connect the current point with it
		var points_relative = PoolVector3Array([
			Vector3(point.x + 1, point.y, point.z),
			Vector3(point.x - 1, point.y, point.z),
			Vector3(point.x, point.y + 1, point.z),
			Vector3(point.x, point.y - 1, point.z),
			Vector3(point.x, point.y, point.z + 1),
			Vector3(point.x, point.y, point.z - 1)
			])
		for point_relative in points_relative:
			var point_relative_index = calculate_point_index(point_relative)

			if (point_relative_index == -1):
				continue
			if not astar_node.has_point(point_relative_index):
				continue
			# Note the 3rd argument. It tells the astar_node that we want the
			# connection to be bilateral: from point A to B and B to A
			# If you set this value to false, it becomes a one-way path
			# As we loop through all points we can set it to false
			astar_node.connect_points(point_index, point_relative_index, false)


# This is a variation of the method above
# It connects cells horizontally, vertically AND diagonally
func astar_connect_walkable_cells_diagonal(points_array):
	for point in points_array:
		var point_index = calculate_point_index(point)
		for local_y in range(3):
			for local_x in range(3):
				var point_relative = Vector2(point.x + local_x - 1, point.y + local_y - 1)
				var point_relative_index = calculate_point_index(point_relative)

				if point_relative == point or is_outside_map_bounds(point_relative):
					continue
				if not astar_node.has_point(point_relative_index):
					continue
				astar_node.connect_points(point_index, point_relative_index, true)


func is_outside_map_bounds(point):
	return point.x < 0 or point.y < 0 or point.x >= map_size.x or point.y >= map_size.y


func calculate_point_index(point):
	var cells = get_used_cells()
	var point_index = -1
	for i in range(cells.size()):
		var cell = cells[i]
		if cell == point:
			point_index = i
	return point_index
	
func _get_offset():
	return Vector3(
			cell_size.x * 0.5 * int(cell_center_x),
			cell_size.y * 0.5 * int(cell_center_y),
			cell_size.z * 0.5 * int(cell_center_z));

func world_to_grid_old(pos):
	var v = pos / cell_size
	return Vector3(stepify(v.x, 1), stepify(v.y, 1), stepify(v.z, 1))

func world_to_grid(pos):
	var offset = _get_offset()
	var v = Vector3(
		pos.x / cell_size.x,
		pos.y / cell_size.y,
		pos.z / cell_size.z
	)
	var cells = get_used_cells()
	var nearest = cells[0]
	for cell in cells:
		if v.distance_to(nearest) > v.distance_to(cell):
			nearest = cell
#	print("Nearest ", nearest)
#	print("Old ", world_to_grid_old(pos))
	return nearest

func grid_to_world(pos):
	var offset = _get_offset();
	var world_pos = Vector3(
		pos.x * cell_size.x, # + offset.x,
		pos.y * cell_size.y, # + offset.y,
		pos.z * cell_size.z # + offset.z
	);
	return world_pos;

func find_path(world_start, world_end):
	_set_path_start_position(world_to_grid(world_start))
	_set_path_end_position(world_to_grid(world_end))
	_recalculate_path()
	var path_world = []
	for point in _point_path:
		var point_world = grid_to_world(Vector3(point.x, point.y, point.z))
		path_world.append(point_world)
	return path_world


func _recalculate_path():
	clear_previous_path_drawing()
	var start_point_index = calculate_point_index(Vector3(path_start_position.x, path_start_position.y, path_start_position.z))
	var end_point_index = calculate_point_index(Vector3(path_end_position.x, path_end_position.y, path_end_position.z))
	var cells = get_used_cells()
	# This method gives us an array of points. Note you need the start and end
	# points' indices as input
	_point_path = astar_node.get_point_path(start_point_index, end_point_index)
	# Redraw the lines and circles from the start to the end point
#	update()


func clear_previous_path_drawing():
	if not _point_path:
		return
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]
#	set_cell_item(point_start.x, point_start.y, point_start.z, 2)
#	set_cell_item(point_end.x, point_end.y, point_end.z, 2)


func _draw():
	if not _point_path:
		return
	var point_start = _point_path[0]
	var point_end = _point_path[len(_point_path) - 1]

#	set_cell_item(point_start.x, point_start.y, point_start.z, 1)
#	set_cell_item(point_end.x, point_end.y, point_end.z, 2)

	var last_point = grid_to_world(Vector3(point_start.x, point_start.y, point_start.z)) # + _half_cell_size
	for index in range(1, len(_point_path)):
		var current_point = grid_to_world(Vector3(_point_path[index].x, _point_path[index].y, _point_path[index].z)) # + _half_cell_size
		last_point = current_point


# Setters for the start and end path values.
func _set_path_start_position(value):
	if value in obstacles:
		return

	path_start_position = value
	if path_end_position and path_end_position != path_start_position:
		_recalculate_path()


func _set_path_end_position(value):
	if value in obstacles:
		return

	path_end_position = value
	if path_start_position != value:
		_recalculate_path()

func handle_hover(selection):
	var cell = find_cell_by_vector(selection.position)
	
