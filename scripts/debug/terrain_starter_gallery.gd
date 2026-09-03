extends Node2D

const SOURCE_ID := 0
const DISPLAY_SCALE := 2.0
const GROUPS := [
	{"name": "GRASS", "y": 0, "tiles": [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]},
	{"name": "DIRT", "y": 1, "tiles": [Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0)]},
	{"name": "FARM SOIL", "y": 2, "tiles": [Vector2i(6, 0), Vector2i(7, 0), Vector2i(8, 0), Vector2i(9, 0), Vector2i(10, 0), Vector2i(11, 0), Vector2i(12, 0), Vector2i(13, 0), Vector2i(14, 0)]},
	{"name": "PATH", "y": 3, "tiles": [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1), Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1), Vector2i(9, 1), Vector2i(10, 1), Vector2i(11, 1), Vector2i(12, 1), Vector2i(13, 1)]},
	{"name": "WATER / SHORE", "y": 4, "tiles": [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2), Vector2i(6, 2), Vector2i(7, 2), Vector2i(8, 2), Vector2i(9, 2)]},
	{"name": "DETAILS", "y": 5, "tiles": [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3)]},
]

@onready var tiles: TileMapLayer = $Tiles


func _ready() -> void:
	for group: Dictionary in GROUPS:
		var row: int = group["y"]
		var atlas_tiles: Array = group["tiles"]
		for index: int in range(atlas_tiles.size()):
			tiles.set_cell(Vector2i(index, row), SOURCE_ID, atlas_tiles[index])
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(640, 360)), Color("#1d2526"))
	var origin := Vector2(164, 54)
	var cell_size := 16.0 * DISPLAY_SCALE
	var grid_color := Color(0.48, 0.58, 0.52, 0.28)
	for group: Dictionary in GROUPS:
		var row: int = group["y"]
		var count: int = group["tiles"].size()
		var y := origin.y + float(row) * cell_size
		for index: int in range(count + 1):
			var x := origin.x + float(index) * cell_size
			draw_line(Vector2(x, y), Vector2(x, y + cell_size), grid_color, 1.0)
		draw_line(Vector2(origin.x, y), Vector2(origin.x + count * cell_size, y), grid_color, 1.0)
		draw_line(Vector2(origin.x, y + cell_size), Vector2(origin.x + count * cell_size, y + cell_size), grid_color, 1.0)
