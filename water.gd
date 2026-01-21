extends Node2D
class_name Water


@export var start_point: Node2D

var points: PackedVector2Array
var line: Line2D = Line2D.new()
var line_width = 16
var collision_layers = 1
var margin = 4
var direction = -1 # Left 



func _physics_process(delta: float)-> void:
	update_water_line()
	draw_water_line()


func draw_water_line() -> void:
	if not line.get_parent():
		add_child(line)

	line.default_color = Color.BLUE
	line.width = line_width
	line.points = points


func update_water_line() -> void:
	var flowing = true
	points = [start_point.position]
	
	while flowing:
		if can_flow_down():
			add_point_below()
		elif can_flow_horizontal():
			add_point_horizontal()

		flowing = not is_done_flowing()


func can_flow_down() -> bool:
	var result = false
	
	var point := Vector2i(
		points[-1].x,
		points[-1].y + line_width * 2,
	)
	
	if get_collisions(point):
		return false

	return true


func can_flow_horizontal() -> bool:
	var result = false
	
	var x = points[-1].x + ((line_width * 2) * direction)
	var point := Vector2i(
		x,
		points[-1].y,
	)
	
	if get_collisions(point):
		return false

	return true


func is_done_flowing() -> bool:
	if is_at_bottom():
		return true

	return false


func is_at_bottom() -> bool:
	var screen_height = get_viewport_rect().size.y
	return points[-1].y == screen_height


func add_point_below() -> void:
	var collision = get_collisions_below()
	
	if not collision:
		points.append(get_bottom_point())
		return
	
	var point := Vector2(
		collision["position"].x,
		collision["position"].y - margin,
	)

	points.append(point)


func add_point_horizontal():
	var increment = ((line_width * 2) * direction)
	var point = Vector2(
		points[-1].x + increment,
		points[-1].y,
	)
	
	# TODO
	# - Add logic to find where we STOP being unable to move down
	var collision = get_collisions(point)
	if not collision: 
		points.append(point)
		return

	point = Vector2(
		collision["position"].x - (margin * direction),
		collision["position"].y,
	)

	points.append(point)
	


func get_collisions_below() -> Dictionary:
	var result = {}

	var screen_height = get_viewport_rect().size.y
	var bottom_point = Vector2(points[-1].x, screen_height)
	result = get_collisions(bottom_point)
	
	return result


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


func get_bottom_point() -> Vector2:
	var screen_height = get_viewport_rect().size.y
	return Vector2(points[-1].x, screen_height)
