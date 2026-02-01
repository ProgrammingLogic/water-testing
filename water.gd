extends Node2D
class_name Water
## A water object.
##
## This water object has a collection of water_lines (streams) that it manages.
##	These water lines start at water's position and flow from there.


@export var tile_map: TileMapLayer

var tile_size: Vector2

var _water_lines: Array[WaterLine] = []


func _ready() -> void:
	tile_size = tile_map.tile_set.tile_size
	add_water_line([
		Vector2.ZERO, 
		Vector2(0, 100)
	])


## Add a water line to the water.
##
## Input:
## - points: PackedVector2Array -> The points the water line is going to start 
## 	with.
func add_water_line(points: PackedVector2Array) -> void:
	assert(not points.is_empty())
	var water_line = WaterLine.new(self, tile_map, points)

	_water_lines.append(water_line)
	add_child(water_line)


## Check if this Water element has the specific point.
##
## Input:
## - query_point: Vector2 -> The point we are querying.
##
## Output
## - has_point: bool -> Whether or not this water object has the point in any
##	of it's water lines.
func has_point(query_point: Vector2) -> bool:
	var query_cell = translate_point_to_tilemap(query_point)

	for water_line in _water_lines:
		for point in water_line.points:
			var cell = translate_point_to_tilemap(point)
			print("calculations:")
			print("\tquery_point: %v, point: %v" % [query_point, point])
			print("\tquery_cell %v, cell %v" % [query_cell, cell])
	
	return false


## Translate a point to it's cell coordinates in the tile_map.
##
## Input:
## - point: Vector2 -> The point to translate to cell coordinates.
## 
## Output:
## - cell_coordinates: Vector2i -> The coordinates the point aligns to on the
##	tile map.
func translate_point_to_tilemap(point: Vector2) -> Vector2i:
	var cell_coordinates: Vector2i = floor(point / tile_size)
	assert(cell_coordinates.x >= 0)
	assert(cell_coordinates.y >= 0)
	return cell_coordinates


## Check if a point is inside the water's viewport.
##
## Input:
## - point: Vector2 -> The point to check.
##
## Output:
## - inside_viewport: bool -> Whether or not the point is inside the viewport.
func is_inside_viewport(point: Vector2) -> bool:
	var viewport_rect = get_viewport_rect()
	return viewport_rect.has_point(point)
