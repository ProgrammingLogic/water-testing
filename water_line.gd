extends Line2D
class_name WaterLine
## A line of water.

var water: Water = null
var starting_points: PackedVector2Array = []
var direction: String = "left" # -1 = left, 1 = right
var size: int

func _init(_water: Water, _points: PackedVector2Array, _direction: String = "left") -> void:
	starting_points = _points
	water = _water
	direction = _direction



func _ready() -> void:
	width = Game.tile_map.tile_set.tile_size.x / 8
	default_color = Color.BLUE
	
	for point in starting_points:
		add_water_point(point)
	
	calculate_points()


func calculate_points():
	# TODO
	# - Get tile_map position of cell
	# - Make sure next_cell is not a part of the Water already
	# - Check for collisions on the tile below (rather than a offset 
	#	of the current tile's center).
	# - When adding a point, translate the point the the "edge" of the closest
	#	wall.
	#	- For water flowing down, hug the left/right wall (which is closer)
	#	- For water flowing left/right, hug the top of the wall below
	#	- For water hitting a tile below, hug the top of the tile below
	while true:
		var get_cell_previous_point = Vector2i.ZERO
		
		var previous_point = points[-1]
		var previous_point_centered = translate_to_cell_center(previous_point)
		var next_point = Vector2.ZERO
		
		var get_down_collision_prev_pnt_ctr = true
		var get_left_collision_prev_pnt_ctr = true
		var get_right_collision_prev_pnt_ctr = true
		
		var get_left_point = Vector2.ZERO
		var get_right_point = Vector2.ZERO
		
		# Calculate collisin on previous point's center 
		# Then place the point according to which edge the water is going to hug
		# This allows us to seperate the visuals from the collisions
		if not get_down_collision_prev_pnt_ctr:
			next_point = get_down_point(previous_point)
		elif direction == "left" and not get_left_collision_prev_pnt_ctr:
			next_point = get_left_point
		elif direction == "right" and not get_right_collision_prev_pnt_ctr:
			next_point = get_right_point
		else:
			break

		if next_point == Vector2.ZERO:
			break

		if not is_inside_viewport(next_point):
			break
		
		assert(next_point != Vector2.ZERO)
		add_water_point(next_point)


## Calculate where the next point in the water line will be.
##
## Input:
## - None
##
## Output:
## - result: Vector2 -> Where the next point will be.
func calculate_next_point() -> Vector2:
	assert(not points.is_empty())

	var previous_point = points[-1]
	assert(previous_point != null)
	assert(previous_point != Vector2.ZERO)

	var down_point = get_down_point(previous_point)
	if not is_colliding(down_point):
		return down_point
	
	return Vector2.ZERO


## Check if the point collides with anything.
##
## Input:
## - point: Vector2 -> The global position of the point to check.
##
## Output:
## - result: bool -> Whether or not the point is colliding.
func is_colliding(point: Vector2) -> bool:
	assert(point != Vector2.ZERO)
	
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = point
	
	var collisions = space_state.intersect_point(query)
	return  not collisions.is_empty()


## Get the point below the specific point.
##
## Input:
## - point: Vector2 -> The global position of the point we want to look below.
##
## Output:
## - down_point: Vector2 -> The centered, global position of the point below.
func get_down_point(point: Vector2) -> Vector2:
	assert(point != Vector2.ZERO)
	var centered_point = translate_to_cell_center(point)
	var tile_size = Game.tile_map.tile_set.tile_size.x
	
	var x = centered_point.x
	var y = centered_point.y + tile_size / 2
	
	var down_point = Vector2(x, y)
	var centered_down_point = translate_to_cell_center(down_point)
	return centered_down_point


## Add a point to the water line.
##
## Input:
## - point: Vector2 -> The global position of the point to add to the water
##	line.
func add_water_point(point: Vector2) -> void:
	assert(not point == Vector2.ZERO)
	assert(is_inside_viewport(point))
	assert(not water.has_point(point))
	var centered_point = translate_to_cell_center(point)
	add_point(centered_point)


## Check if a point is inside the current viewport.
##
## Input:
## - point: Vector2 -> The global position of the point to chekck
##
## Output:
## - result: bool -> Whether or not the point is inside the viewport.
func is_inside_viewport(point: Vector2) -> bool:
	var viewport_rect := get_viewport_rect()
	assert(viewport_rect != null)
	assert(viewport_rect.size > Vector2.ZERO)
	var result = viewport_rect.has_point(point)
	return result


## Get the point's position translated to the center of the tile map
## 
## Input:
## - point: Vector2 -> The global position of the point to translate.
##
## Output
## - translated_point: Vector2 -> The point centered on it's position in the 
##	tile map
func translate_to_cell_center(point: Vector2) -> Vector2:
	var tile_map = Game.tile_map
	var tile_size = tile_map.tile_set.tile_size as Vector2

	var cell_cordinates = floor(point / tile_size)
	var cell_position = cell_cordinates * tile_size
	
	var translated_point = cell_position + tile_size / 2
	
	return translated_point


## Translate the point to it's global position. 
##
## Input:
## - point: Vector2 -> The point to translate to it's global position.
##
## Ouput:
## - translated_point: Vector2 -> The point trnaslated to it's global position
func translate_to_global_point(point: Vector2) -> Vector2:
	return point + water.position


## Translate an array of points to their global position. 
##
## Input:
## - points: PackedVector2Array -> A list of points to translate to their
##	global position. 
## 
## Output:
## - translated_points: PackedVector2Array -> The list of points translated to their
##	global positions.
func translate_to_global_points(_points: PackedVector2Array) -> PackedVector2Array:
	var translated_points: PackedVector2Array = []
	var water_pos: Vector2 = water.position

	for point in _points:
		translated_points.append(point + water_pos)

	return translated_points


## Translate the point to it's local position. 
##
## Input:
## - point: Vector2 -> The point to translate to it's local position.
##
## Ouput:
## - translated_point: Vector2 -> The point translated to it's local position
func translate_to_local_point(point: Vector2) -> Vector2:
	return point - water.position
