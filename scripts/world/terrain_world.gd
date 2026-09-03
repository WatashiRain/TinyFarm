class_name TerrainWorld
extends Node2D

const SOURCE_ID := 0
const GRASS_TILES := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0)]
const FARM_CENTER := Vector2i(8, 0)
const FARM_HORIZONTAL_EDGE := Vector2i(9, 0)
const FARM_VERTICAL_EDGE := Vector2i(10, 0)
const FARM_CORNERS := [Vector2i(11, 0), Vector2i(12, 0), Vector2i(13, 0), Vector2i(14, 0)]
const PATH_CENTER := Vector2i(0, 1)
const PATH_EDGES := [Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1)]
const PATH_CORNERS := [Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1)]
const PATH_VARIATION := Vector2i(13, 1)
const WATER_CENTER := Vector2i(0, 2)
const WATER_VARIATION := Vector2i(1, 2)
const SHORE_EDGES := [Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2), Vector2i(5, 2)]
const SHORE_CORNERS := [Vector2i(6, 2), Vector2i(7, 2), Vector2i(8, 2), Vector2i(9, 2)]
const DETAIL_TILES := [Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3)]

@export var terrain_tileset: TileSet

@onready var ground_layer: TileMapLayer = $GroundLayer
@onready var terrain_layer: TileMapLayer = $TerrainLayer
@onready var water_layer: TileMapLayer = $WaterLayer
@onready var detail_layer: TileMapLayer = $DetailLayer


func _ready() -> void:
	for layer: TileMapLayer in [ground_layer, terrain_layer, water_layer, detail_layer]:
		layer.tile_set = terrain_tileset
		layer.clear()
	_populate_ground()
	_populate_farm_patch()
	_populate_path()
	_populate_pond()
	_populate_details()


func _populate_ground() -> void:
	for y: int in range(-12, 36):
		for x: int in range(-20, 60):
			var roll := posmod(x * 37 + y * 61 + x * y * 3, 100)
			var atlas := GRASS_TILES[0]
			if roll >= 95:
				atlas = GRASS_TILES[2]
			elif roll >= 87:
				atlas = GRASS_TILES[1]
			ground_layer.set_cell(Vector2i(x, y), SOURCE_ID, atlas)


func _populate_farm_patch() -> void:
	var farm := Rect2i(6, 11, 12, 7)
	for y: int in range(farm.position.y, farm.end.y):
		for x: int in range(farm.position.x, farm.end.x):
			var local_x := x - farm.position.x
			var local_y := y - farm.position.y
			var atlas := FARM_CENTER
			if local_x == 0 and local_y == 0:
				atlas = FARM_CORNERS[0]
			elif local_x == farm.size.x - 1 and local_y == 0:
				atlas = FARM_CORNERS[1]
			elif local_x == 0 and local_y == farm.size.y - 1:
				atlas = FARM_CORNERS[2]
			elif local_x == farm.size.x - 1 and local_y == farm.size.y - 1:
				atlas = FARM_CORNERS[3]
			elif local_y == 0 or local_y == farm.size.y - 1:
				atlas = FARM_HORIZONTAL_EDGE
			elif local_x == 0 or local_x == farm.size.x - 1:
				atlas = FARM_VERTICAL_EDGE
			terrain_layer.set_cell(Vector2i(x, y), SOURCE_ID, atlas)


func _populate_path() -> void:
	var cells: Dictionary[Vector2i, bool] = {}
	var spans := {
		10: Vector2i(18, 21), 11: Vector2i(18, 21), 12: Vector2i(19, 22),
		13: Vector2i(20, 23), 14: Vector2i(20, 23), 15: Vector2i(19, 22),
		16: Vector2i(20, 23), 17: Vector2i(20, 23), 18: Vector2i(19, 22),
		19: Vector2i(19, 22), 20: Vector2i(18, 21), 21: Vector2i(18, 21),
		22: Vector2i(17, 20), 23: Vector2i(17, 20),
	}
	for y: int in spans:
		var span: Vector2i = spans[y]
		for x: int in range(span.x, span.y + 1):
			cells[Vector2i(x, y)] = true
	for cell: Vector2i in cells:
		terrain_layer.set_cell(cell, SOURCE_ID, _path_tile_for(cell, cells))


func _path_tile_for(cell: Vector2i, cells: Dictionary[Vector2i, bool]) -> Vector2i:
	var top := cells.has(cell + Vector2i.UP)
	var bottom := cells.has(cell + Vector2i.DOWN)
	var left := cells.has(cell + Vector2i.LEFT)
	var right := cells.has(cell + Vector2i.RIGHT)
	if not top and not left:
		return PATH_CORNERS[0]
	if not top and not right:
		return PATH_CORNERS[1]
	if not bottom and not left:
		return PATH_CORNERS[2]
	if not bottom and not right:
		return PATH_CORNERS[3]
	if not top:
		return PATH_EDGES[0]
	if not bottom:
		return PATH_EDGES[1]
	if not left:
		return PATH_EDGES[2]
	if not right:
		return PATH_EDGES[3]
	return PATH_VARIATION if posmod(cell.x * 11 + cell.y * 17, 7) == 0 else PATH_CENTER


func _populate_pond() -> void:
	var cells: Dictionary[Vector2i, bool] = {}
	var spans := {
		11: Vector2i(29, 31), 12: Vector2i(27, 33), 13: Vector2i(26, 34),
		14: Vector2i(25, 35), 15: Vector2i(25, 35), 16: Vector2i(26, 34),
		17: Vector2i(27, 33), 18: Vector2i(29, 31),
	}
	for y: int in spans:
		var span: Vector2i = spans[y]
		for x: int in range(span.x, span.y + 1):
			cells[Vector2i(x, y)] = true
	for cell: Vector2i in cells:
		water_layer.set_cell(cell, SOURCE_ID, _water_tile_for(cell, cells))


func _water_tile_for(cell: Vector2i, cells: Dictionary[Vector2i, bool]) -> Vector2i:
	var top := cells.has(cell + Vector2i.UP)
	var bottom := cells.has(cell + Vector2i.DOWN)
	var left := cells.has(cell + Vector2i.LEFT)
	var right := cells.has(cell + Vector2i.RIGHT)
	if not top and not left:
		return SHORE_CORNERS[0]
	if not top and not right:
		return SHORE_CORNERS[1]
	if not bottom and not left:
		return SHORE_CORNERS[2]
	if not bottom and not right:
		return SHORE_CORNERS[3]
	if not top:
		return SHORE_EDGES[0]
	if not bottom:
		return SHORE_EDGES[1]
	if not left:
		return SHORE_EDGES[2]
	if not right:
		return SHORE_EDGES[3]
	return WATER_VARIATION if posmod(cell.x * 13 + cell.y * 19, 6) == 0 else WATER_CENTER


func _populate_details() -> void:
	var placements := [
		Vector3i(3, 5, 0), Vector3i(8, 4, 0), Vector3i(15, 7, 2),
		Vector3i(23, 6, 0), Vector3i(30, 8, 2), Vector3i(36, 5, 0),
		Vector3i(4, 20, 2), Vector3i(14, 20, 1), Vector3i(24, 21, 0),
		Vector3i(37, 19, 0), Vector3i(9, 7, 1), Vector3i(33, 21, 2),
	]
	for placement: Vector3i in placements:
		detail_layer.set_cell(Vector2i(placement.x, placement.y), SOURCE_ID, DETAIL_TILES[placement.z])
