extends Line2D
class_name WaterLine


var water: Water = null
var starting_points: PackedVector2Array = []
var collision_layers = 1 # Wall
var direction: int = 0 # -1 = left, 1 = right
var margin: int = 8

var shape := CollisionShape2D.new()
var static_body := StaticBody2D.new()
var segments: Array[SegmentShape2D] = []


func _init(w: Water, s_points: PackedVector2Array, dir: int = -1) -> void:
	water = w
	starting_points = s_points
	direction = dir


func _ready() -> void:
	width = water.LINE_WIDTH
	default_color = Color.BLUE
	
	calculate_points()


func calculate_points():
	points = [starting_points]

	while true:
		if is_at_bottom():
			break

		if is_outside_viewport():
			break

		if can_flow_down():
			add_point_below()

		elif can_flow_horizontal():
			add_left_point()
			#add_right_point()

		else:
			break


func is_at_bottom() -> bool:
	var screen_height = get_viewport_rect().size.y
	return points[-1].y == screen_height


func is_outside_viewport() -> bool:
	return not get_viewport_rect().has_point(points[-1])


func can_flow_down() -> bool:
	var result = false
	
	var point := Vector2i(
		points[-1].x,
		points[-1].y + width * 2,
	)
	
	if get_collisions(point):
		return false

	return true


func can_flow_horizontal() -> bool:
	var result = false
	
	print("water.position: (%d, %d)" % [water.position.x, water.position.y])
	
	for i in points.size() - 1:
		var point: Vector2 = points[i]
		print("\tpoint %d position: (%d, %d)" % [i, point.x, point.y])

	for i in points.size() - 1:
		var point: Vector2 = points[i] + water.position
		print("\tpoint %d position + water.position: (%d, %d)" % [i, point.x, point.y])
	
	var last_point = points[-1]
	var x_offset = last_point.x + (width * direction)
	var new_point = Vector2(x_offset, last_point.y)
	
	print("last point, not transformed:")
	Game.debug_draw_line(last_point, new_point, 5.0, Color.BEIGE)
	print("\tlast_point: (%d, %d)" % [last_point.x, last_point.y])
	print("\tx_offset: %d" % [x_offset])
	print("\tnew_point: (%d, %d)" % [new_point.x, new_point.y])
	
	var last_point_water_offset = points[-1] + water.position
	var x_offset_water_offset = last_point_water_offset.x + (width * direction)
	var new_point_water_offset = Vector2(x_offset_water_offset, last_point_water_offset.y)
	print("last point, transformed:")
	Game.debug_draw_line(last_point_water_offset, new_point_water_offset, 7.0, Color.BLACK)
	print("\tlast_point: (%d, %d)" % [last_point_water_offset.x, last_point_water_offset.y])
	print("\tx_offset: %d" % [x_offset_water_offset])
	print("\tnew_point_water_offset: (%d, %d)" % [new_point_water_offset.x, new_point_water_offset.y])
	
	#var t_last_point = points[-1] * global_transform * -1
	#var t_x_offset = last_point.x + (width * direction)
	#var t_new_point = Vector2(t_x_offset, t_last_point.y)
	#
	#Game.debug_draw_line(t_last_point, t_new_point, 10.0, Color.GREEN)
	#
	#print("global transform: (%d, %d)" % [global_transform.x, global_transform.y])
	#print("t_last_point: (%d, %d)" % [t_last_point.x, t_last_point.y])
	#print("t_x_offset: %d" % [t_x_offset])
	#print("t_new_point: (%d, %d)" % [t_new_point.x, t_new_point.y])

	
	if get_collisions(new_point):
		return false

	return true


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
	
	add_point(left_point)

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
	var collision = get_collisions_below()
	
	if not collision:
		add_point(get_bottom_point())
		return
	
	var point := Vector2(
		collision["position"].x,
		collision["position"].y - margin,
	)
	
	add_point(point)


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

	point = Vector2(
		collision["position"].x - (margin * direction),
		collision["position"].y - margin,
	)

	add_point(point)


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


func get_collisions(point: Vector2) -> Dictionary:
	var result = {}
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		points[-1], 
		point,
		collision_layers,
	)
	
	result = space_state.intersect_ray(query)
	return result


func get_collisions_below() -> Dictionary:
	var result = {}

	var screen_height = get_viewport_rect().size.y
	var bottom_point = Vector2(points[-1].x, screen_height)
	result = get_collisions(bottom_point)
	
	return result
