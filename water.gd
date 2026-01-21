extends Node2D
class_name Water


@export var start_point: Node2D

var points: PackedVector2Array
var line: Line2D = Line2D.new()
var stopped = false
var collision_layers = 1


func _process(delta: float) -> void:
	update_water_line()
	draw_water_line()


func draw_water_line() -> void:
	if not line.get_parent():
		add_child(line)

	line.default_color = Color.BLUE
	line.width = 10
	line.points = points


func update_water_line() -> void:
	stopped = false
	points = [start_point.position]
	
	add_point_below()


func add_point_below() -> void:
	var collision = get_collisions_below()
	
	if not collision:
		points.append(get_bottom_point())
		return
		
	points.append(collision["position"])


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
