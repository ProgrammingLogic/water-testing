extends Line2D
class_name WaterLine
## Line representing a water stream in a Water object.
##
## Input:
## - water: Water -> The water object this water_line is a part of.
## - tile_map: TileMapLayer -> The tilemap this water line is drawn on.
## - starting_points: PackedVector2Array -> The points this water line starts
##	on.
## - flow_direction: Vector2i -> The direction the water is flowing.
##	Defaults to Vector2i.DOWN.

var _tile_map: TileMapLayer
var _tile_size: Vector2i
var _water: Water
var _starting_points: PackedVector2Array
var _flow_direction: Vector2i


func _init(water: Water, tile_map: TileMapLayer, starting_points: PackedVector2Array, flow_direction := Vector2i.DOWN) -> void:
	_water = water
	_tile_map = tile_map
	_starting_points = starting_points
	_tile_size = _tile_map.tile_set.tile_size
	_flow_direction = flow_direction

	default_color = Color.BLUE
	width = _tile_size.x / 4


func _ready() -> void:
	assert(not _starting_points.is_empty())
	assert(not _tile_size == null)
	assert(not _tile_size == Vector2i.ZERO)

	for point in _starting_points:
		add_water_point(point)

	flow()
	assert(points.size() > _starting_points.size())


## Calculates the water points for this water line, and then adds them to the
##	water line.
##
## Input:
## - None
##
## Output:
## - None
func flow() -> void:
	assert(not _starting_points.is_empty())
	assert(not points.size() > _starting_points.size())

	while true:
		var next_water_points := get_next_water_points()
		var is_empty = next_water_points.is_empty()

		if next_water_points.is_empty():
			return

		var next_point = next_water_points.pop_front()
		var next_point_direction = next_point["direction"]
		var next_point_vector = next_point["point"]
		_flow_direction = next_point_direction
		add_water_point(next_point_vector)

		if next_water_points.is_empty():
			return

		while not next_water_points.is_empty():
			next_point = next_water_points.pop_front()
			next_point_direction = next_point["direction"]
			next_point_vector = next_point["point"]
			_water.add_water_line([next_point_vector], next_point_direction)

	return


## Calculate the next water points and their direction from the current point.
##
## Using a set of rules, this function will determine the next points in the
##	water line, and the direction those points are from the current point.
##
## If there are multiple cells returned, it is assumed the caller of this
##	function will determine what to do with the additional cells.
##
## Input:
## - None
##
## Output:
## - next_water_points: Array[Dictionary]
## 		[{
##			point: Vector2,
##			direction: Vector2i
##		}]
func get_next_water_points() -> Array[Dictionary]:
	var next_water_points: Array[Dictionary] = []

	assert(not points.is_empty())
	var current_water_point = points[-1]
	assert(_water.is_point_valid(current_water_point))

	var point_below = _water.translate_point_to_direction(current_water_point, Vector2i.DOWN)
	var point_left = _water.translate_point_to_direction(current_water_point, Vector2i.LEFT)
	var point_right = _water.translate_point_to_direction(current_water_point, Vector2i.RIGHT)

	if can_flow_to(point_below):
		next_water_points.append({
			"point": point_below,
			"direction": Vector2i.DOWN,
		})
		return next_water_points

	if can_flow_to(point_left):
		next_water_points.append({
			"point": point_left,
			"direction": Vector2i.LEFT,
		})

	if can_flow_to(point_right):
		next_water_points.append({
			"point": point_right,
			"direction": Vector2i.RIGHT,
		})

	return next_water_points


## Checks if the water line can flow to the point.
##
## Input:
## - point: Vector2 -> The point to check.
##
## Output:
## - result: bool -> Whether or not the water line can flow to point.
func can_flow_to(point: Vector2) -> bool:
	if not _water.is_point_valid(point):
		return false

	if not _water.is_colliding(point):
		return false

	return true


## Add a water point to the WaterLine's line.
##
## Determines where in a cell the point should be added (center, right, left,
## 	bottom center), and then adds a point at that position to the WaterLine.
##
## Input:
## - point: Vector2 -> The position of the cell we want to add a point to.
##
## Output:
## - None
func add_water_point(point: Vector2) -> void:
	assert(_water.is_point_valid(point))

	# It's okay if another water line already has our starting points, because
	#	there are circumstances where a water line will "split off" from
	#	another water line, and they need to be able to connect.
	if not _starting_points.has(point):
		assert(not _water.has_point(point))

	add_point(point)
