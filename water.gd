extends Node2D
class_name Water


@export var tile_map: TileMapLayer


var _water_lines: Array[WaterLine] = []


func _ready() -> void:
	await tile_map.ready
	_water_lines.append(WaterLine.new(self, tile_map))
