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
	add_water_line([Vector2.ZERO])


## Add a water line to the water.
##
## Input:
## - points: PackedVector2Array -> The points the water line is going to start
## 	with.
## - flow_direction: Vector2i -> The direction the water is flowing.
##
## Output:
## - None
func add_water_line(points: PackedVector2Array, flow_direction := Vector2i.DOWN) -> void:
	assert(not points.is_empty())
	var water_line = WaterLine.new(self, tile_map, points, flow_direction)

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
	var global_query_point = to_global(query_point)

	var local_tile_map_query_point := tile_map.to_local(global_query_point)
	var tile_map_cords_query_point := tile_map.local_to_map(
		local_tile_map_query_point
	)

	for water_line in _water_lines:
		for point in water_line.points:
			var global_point := to_global(point)

			var local_tile_map_point := tile_map.to_local(global_point)
			var tile_map_cords_point = tile_map.local_to_map(local_tile_map_point)

			if tile_map_cords_query_point == tile_map_cords_point:
				print("query:")
				print("\tglobal_query_point: %v, global_point: %v" % [global_query_point, global_point])
				print("\ttile_map_cords_query_point: %v, tile_map_cords_point: %v"
					% [tile_map_cords_query_point, tile_map_cords_point])
				return true

	return false


## Translate a local point by a number of tiles equal to direction.
##
## This function takes the local point, translates it to water's position,
##	and then determines moves that point towards direction, where the distance
## 	it's translated is equal to tile_size * direction.
##
## Input:
## - point: Vector2 -> The point to translate.
## - direction: Vector2i -> How many tiles to move in each direction.
##
## Output:
## - translated_point: Vector2 -> The local point translated by direction tiles.
func translate_point_to_direction(point: Vector2, direction: Vector2i) -> Vector2:
	var global_point = to_global(point)

	var translation = direction as Vector2 * tile_size

	var translated_global_point = global_point + translation
	var translated_point = to_local(translated_global_point)

	return translated_point


## Translate a local water point to a position centered to the tile map.
##
## Input:
## - point: Vector2 -> The point to center.
##
## Output:
## - centered_point_global -> The point's global position centered on a tile.
func translate_point_to_tile_center(point: Vector2) -> Vector2:
	var global_point := to_global(point)

	var local_tile_map_point := tile_map.to_local(global_point)
	var tile_map_cords = tile_map.local_to_map(local_tile_map_point)

	var centered_local_tile_map_point = tile_map.map_to_local(tile_map_cords)
	var centered_global_point = tile_map.to_global(centered_local_tile_map_point)

	var centered_local_point = to_local(centered_global_point)

	return centered_local_point


## Checks if the local point is valid.
##
## Input:
## - point: Vector2 -> The point to check.
##
## Output:
## - result: bool -> Whether or not the point is valid.
func is_point_valid(point: Vector2) -> bool:
	if not is_inside_viewport(point):
		return false

	return true


## Check if a local point is inside the viewport.
##
## Input:
## - point: Vector2 -> The local point to check.
##
## Output:
## - inside_viewport: bool -> Whether or not the point is inside the viewport.
func is_inside_viewport(point: Vector2) -> bool:
	var global_point = to_global(point)
	var viewport_rect = get_viewport_rect()
	return viewport_rect.has_point(global_point)


## Checks whether or not the local point is colliding with something.
##
## Uses physics layer 1 for collisions.
##
## Input:
## - point: Vector2 -> The local point to check for collisions at.
##
## Output:
## - result: bool -> Whether or not the point is colliding with something.
func is_colliding(point: Vector2) -> bool:
	var global_point = to_global(point)

	var space_state = get_world_2d().direct_space_state
	assert(space_state != null)

	var ray_query_parameters = PhysicsPointQueryParameters2D.new()
	ray_query_parameters.position = global_point

	var collisions := space_state.intersect_point(ray_query_parameters)
	return not collisions.is_empty()
