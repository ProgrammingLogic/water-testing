extends Node2D
class_name Water


@export var start_point: Node2D

var points: PackedVector2Array
var line: Line2D = Line2D.new()


func _ready() -> void:
	update_water_line()
	draw_water_line()


func draw_water_line() -> void:
	if not line.get_parent():
		add_child(line)

	line.default_color = Color.BLUE
	line.width = 10
	line.points = points


func update_water_line() -> void:
	points = [start_point.position]
	
	if not get_collisions_below():
		points.append(get_bottom_point())


func get_collisions_below() -> Dictionary:
	var screen_height = get_viewport_rect().size.y
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		start_point.position, 
		Vector2(start_point.position.x, screen_height)
	)
	
	return space_state.intersect_ray(query)


func get_bottom_point() -> Vector2:
	var screen_height = get_viewport_rect().size.y
	return Vector2(points[-1].x, screen_height)
	
