extends Node2D
class_name Water


const LINE_WIDTH = 8

var water_lines: Array[WaterLine] = []
var update_timer := Timer.new()


func _ready() -> void:
	add_water_line([position], -1)
	
	update_timer.timeout.connect(update)
	add_child(update_timer)
	update_timer.start(0.1)


func update() -> void:
	clear_water()
	add_water_line([position], -1)


func clear_water() -> void:
	for water_line in water_lines:
		water_line.queue_free()
	
	water_lines = []


func has_point(point: Vector2) -> bool:
	for water_line in water_lines:
		if water_line.points.find(point) > -1:
			return true
	
	return false


func add_water_line(starting_points: PackedVector2Array, dir: int) -> void:
	var water_line = WaterLine.new(self, starting_points, dir)
	water_lines.append(water_line)
	add_child(water_line)
