extends Line2D
class_name WaterLine
## Line representing a water stream in a Water object.
##
## Input:
## - water: Water -> The water object this water_line is a part of.
## - tile_map: TileMapLayer -> The tilemap this water line is drawn on.
## - starting_points: PackedVector2Array -> The points this water line starts
##	on.

var _tile_map: TileMapLayer
var _tile_size: Vector2
var _water: Water
var _starting_points: PackedVector2Array


func _init(water: Water, tile_map: TileMapLayer, starting_points: PackedVector2Array) -> void:
	_water = water
	_tile_map = tile_map
	_starting_points = starting_points
	_tile_size = _tile_map.tile_set.tile_size
	
	default_color = Color.BLUE
	width = _tile_size.x / 4


func _ready() -> void:
	assert(not _starting_points.is_empty())
	
	for point in _starting_points:
		add_water_point(point)


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
	assert(_water.is_inside_viewport(point))
	
	# It's okay if another water line already has our starting points, because
	#	there are circumstances where a water line will "split off" from
	#	another water line, and they need to be able to connect.
	if not _starting_points.has(point):
		assert(not _water.has_point(point))

	add_point(point)
