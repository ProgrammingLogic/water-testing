extends Node2D


var tile_map: TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func debug_draw_line(start_point: Vector2, end_point: Vector2, duration := 10.00, color := Color.MAGENTA) -> void:
	var debug_line := Line2D.new()
	debug_line.default_color = color
	debug_line.add_point(start_point)
	debug_line.add_point(end_point)
	debug_line.z_index = 500

	var timer := Timer.new()
	timer.timeout.connect(func():
		debug_line.queue_free()
	)

	add_child(debug_line)
	debug_line.add_child(timer)
	timer.start(duration)
