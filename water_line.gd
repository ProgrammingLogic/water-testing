extends Line2D
class_name WaterLine

## Line representing a water stream in a Water object.

var _tile_map: TileMapLayer
var _water: Water


func _init(water: Water, tile_map: TileMapLayer) -> void:
	_water = water
	_tile_map = tile_map
