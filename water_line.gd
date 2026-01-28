extends Line2D
class_name WaterLine
## A line of water.

var water: Water = null
var starting_points: PackedVector2Array = []
var collision_layers = 1 # Wall
var direction: int = 0 # -1 = left, 1 = right
var margin: int = 8

var shape := CollisionShape2D.new()
var static_body := StaticBody2D.new()
var segments: Array[SegmentShape2D] = []

func _init(_water: Water, _points: PackedVector2Array, _direction: int = -1) -> void:
	starting_points = _points
	water = _water
	direction = _direction



func _ready() -> void:
	width = water.LINE_WIDTH
	default_color = Color.BLUE
	
	for point in starting_points:
		add_water_point(point)
	
	calculate_points()


func calculate_points():
	while true:
		var next_point = calculate_next_point()

		if not is_inside_viewport(next_point):
			break
		
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
	
	return down_point

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
	var tile_size_x = Game.tile_map.tile_set.tile_size.x
	var tile_size_y = Game.tile_map.tile_set.tile_size.y
	
	var x = centered_point.x
	var y = centered_point.y + tile_size_y / 2
	
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



#region Checks for the waterline.
func is_at_bottom() -> bool:
	var screen_height = get_viewport_rect().size.y
	return points[-1].y == screen_height


func can_flow_down() -> bool:
	#print("points")
	#print("\twater.position: %.0v" % water.position)
	#
	#print("\tpoints not transformed")
	#for point in points:
		#print("\t\t%v" % point)
#
	#print("\tpoints transformed by water.position")
	#for point in translate_to_global_points():
		#print("\t\t%v" % point)

	var result = false
	
	var point := Vector2i(
		points[-1].x,
		points[-1].y + width * 2,
	)
	
	#print("\tnew_point: %v" % point)
	#print("\tnew_point_global: %v" % translate_to_global_point(point))
	#Game.debug_draw_line(translate_to_global_point(points[0]), translate_to_global_point(point), 10, Color.YELLOW)
	
	if get_collisions(point):
		return false

	return true


func can_flow_horizontal() -> bool:
	var result = false
	print("points")
	print("\twater.position: %.0v" % water.position)
	
	print("\tpoints not transformed")
	for point in points:
		print("\t\t%v" % point)

	print("\tpoints transformed by water.position")
	for point in translate_to_global_points(points):
		print("\t\t%v" % point)
	
	var last_point = points[-1]
	var x_offset = last_point.x - 8
	var new_point = Vector2(last_point.x + x_offset, last_point.y)
	Game.debug_draw_line(translate_to_global_point(last_point), translate_to_global_point(new_point), 5.0, Color.YELLOW)
	print("\tlast point, not transformed:")
	print("\t\tlast_point: %v" % last_point)
	print("\t\tx_offset: %d" % x_offset)
	print("\t\tnew_point: %v" % new_point)

	
	if get_collisions(new_point):
		return false

	return true
#endregion


#region Add points to the water line.
func add_left_point():
	var current_point = points[-1]
	# Don't return Vector2 until we find a point we can go down at, 
	# 	or we reach the edge of the screen.
	var left_point = get_left_point()
	if water.has_point(left_point):
		pass # Don't add left point

	# If right water_line, create left waterline
	if direction == -1: 
		water.add_child(WaterLine.new(
			water,
			[current_point, left_point],
			direction * -1,
		))
	
	add_water_point(left_point)


func add_right_point():
	var current_point = points[-1]
	var right_point = get_right_point()

	if water.has_point(right_point):
		pass # Don't add right point

	# If left water_line, create right waterline
	if direction == -1: # If left water_line
		water.add_child(WaterLine.new(
			water,
			[current_point, right_point],
			direction * -1,
		))
	
	add_point(right_point)


func add_point_below() -> void:
	var collision: Vector2 = get_collisions_below()
	
	if not collision:
		print("nothing below")
		add_point(get_bottom_point())
		return
	
	print("something below")
	
	add_point(collision)


func add_point_horizontal():
	var increment = ((width * 2) * direction)
	var point = Vector2(
		points[-1].x + increment,
		points[-1].y,
	)
	
	# TODO
	# - If laggy, add logic to find where we STOP being unable to move down
	var collision = get_collisions(point)
	if not collision: 
		points.append(point)
		return

	point = collision

	add_point(point)
#endregion


#region Get Points -> Methods to get certain important points on the WaterLine.
func get_bottom_point() -> Vector2:
	var screen_height = get_viewport_rect().size.y
	return Vector2(points[-1].x, screen_height)


func get_left_point() -> Vector2:
	# Don't return Vector2 until we find a point we can go down at, 
	# 	or we reach the edge of the screen.
	var result := Vector2i.ZERO
	var next_point := Vector2i.ZERO
	var current_point = points[-1]
	
	var x = current_point.x 

	
	while true:
		x -= width * 2

		next_point = Vector2i(
			x,
			current_point.y
		)
		
		if not get_viewport_rect().has_point(next_point):
			return result
		
		# If we're running into something, we don't want to go any more left
		if get_collisions(next_point):
			return result

		var next_point_down = Vector2i(
			x,
			current_point.y + width * 2,
		)
		
		# If the space below where we're about to go is empty, we want to go to the next space.
		if get_collisions(next_point_down):
			result = next_point
			return result 
		
		result = next_point

	return result


func get_right_point() -> Vector2:
	# Don't return Vector2 until we find a point we can go down at, 
	# 	or we reach the edge of the screen.
	return Vector2.ZERO


func get_collisions(point: Vector2) -> Vector2:
	Game.debug_draw_line(translate_to_global_point(points[-1]), translate_to_global_point(point), 2, Color.YELLOW)

	#var query = PhysicsRayQueryParameters2D.create(
		#points[-1], 
		#point,
		#collision_layers,
	#)
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		translate_to_global_point(points[-1]), 
		translate_to_global_point(point),
		collision_layers,
	)
	var collision = space_state.intersect_ray(query)
	
	if collision.is_empty():
		return Vector2.ZERO

	Game.debug_draw_line(translate_to_global_point(points[-1]), translate_to_global_point(point), 5, Color.RED)

	var global_collision_point = collision["position"]
	var local_collision_point = translate_to_local_point(global_collision_point)
	return local_collision_point


func get_collisions_below() -> Vector2:
	var result = {}

	var screen_height = get_viewport_rect().size.y
	var bottom_point = Vector2(points[-1].x, screen_height)
	result = get_collisions(bottom_point)
	
	return result
#endregion
