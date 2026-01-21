extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var start_point = $Water/Start
	var water = Water.new(start_point.position)
	add_child(water)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
