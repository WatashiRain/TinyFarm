extends SceneTree

const TILE_SIZE := 16
const SHEET_SIZE := Vector2i(256, 256)
const PREVIEW_SCALE := 8
const SHEET_PATH := "res://art/terrain/terrain_starter_v01.png"
const PREVIEW_PATH := "res://art/terrain/terrain_starter_v01_preview.png"
const TILESET_PATH := "res://resources/tilesets/terrain_starter_v01.tres"

const P := {
	"grass_dark": Color8(63, 117, 71),
	"grass": Color8(82, 145, 79),
	"grass_light": Color8(112, 173, 92),
	"grass_highlight": Color8(145, 201, 104),
	"soil_deep": Color8(94, 59, 53),
	"soil_dark": Color8(112, 69, 56),
	"soil": Color8(167, 106, 80),
	"soil_light": Color8(201, 133, 96),
	"sand_dark": Color8(188, 118, 80),
	"sand": Color8(210, 164, 101),
	"sand_light": Color8(231, 201, 132),
	"stone_dark": Color8(96, 113, 106),
	"stone": Color8(126, 142, 131),
	"cream": Color8(242, 230, 188),
	"yellow": Color8(231, 185, 76),
	"water_deep": Color8(36, 105, 111),
	"water": Color8(52, 139, 142),
	"water_light": Color8(79, 170, 159),
	"water_glint": Color8(167, 211, 176),
}

const TILE_COORDS := [
	Vector2i(0, 0), Vector2i(1, 0), Vector2i(2, 0),
	Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0),
	Vector2i(6, 0), Vector2i(7, 0), Vector2i(8, 0), Vector2i(9, 0), Vector2i(10, 0),
	Vector2i(11, 0), Vector2i(12, 0), Vector2i(13, 0), Vector2i(14, 0),
	Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1), Vector2i(4, 1),
	Vector2i(5, 1), Vector2i(6, 1), Vector2i(7, 1), Vector2i(8, 1),
	Vector2i(9, 1), Vector2i(10, 1), Vector2i(11, 1), Vector2i(12, 1), Vector2i(13, 1),
	Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2),
	Vector2i(5, 2), Vector2i(6, 2), Vector2i(7, 2), Vector2i(8, 2), Vector2i(9, 2),
	Vector2i(0, 3), Vector2i(1, 3), Vector2i(2, 3), Vector2i(3, 3),
]


func _initialize() -> void:
	call_deferred("_generate")


func _generate() -> void:
	var sheet := Image.create(SHEET_SIZE.x, SHEET_SIZE.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0, 0, 0, 0))

	_draw_grass(sheet, Vector2i(0, 0), 0)
	_draw_grass(sheet, Vector2i(1, 0), 1)
	_draw_grass(sheet, Vector2i(2, 0), 2)
	_draw_dirt(sheet, Vector2i(3, 0), 0)
	_draw_dirt(sheet, Vector2i(4, 0), 1)
	_draw_dirt(sheet, Vector2i(5, 0), 2)
	_draw_farm_soil(sheet, Vector2i(6, 0), false, false)
	_draw_farm_soil(sheet, Vector2i(7, 0), true, false)
	_draw_farm_soil(sheet, Vector2i(8, 0), false, true)
	_draw_tilled_edge(sheet, Vector2i(9, 0), true)
	_draw_tilled_edge(sheet, Vector2i(10, 0), false)
	for corner: int in range(4):
		_draw_tilled_corner(sheet, Vector2i(11 + corner, 0), corner)

	_draw_path_center(sheet, Vector2i(0, 1), false)
	_draw_path_edge(sheet, Vector2i(1, 1), 0)
	_draw_path_edge(sheet, Vector2i(2, 1), 1)
	_draw_path_edge(sheet, Vector2i(3, 1), 2)
	_draw_path_edge(sheet, Vector2i(4, 1), 3)
	for corner: int in range(4):
		_draw_path_corner(sheet, Vector2i(5 + corner, 1), corner, false)
		_draw_path_corner(sheet, Vector2i(9 + corner, 1), corner, true)
	_draw_path_center(sheet, Vector2i(13, 1), true)

	_draw_water(sheet, Vector2i(0, 2), false)
	_draw_water(sheet, Vector2i(1, 2), true)
	_draw_shore_edge(sheet, Vector2i(2, 2), 0)
	_draw_shore_edge(sheet, Vector2i(3, 2), 1)
	_draw_shore_edge(sheet, Vector2i(4, 2), 2)
	_draw_shore_edge(sheet, Vector2i(5, 2), 3)
	for corner: int in range(4):
		_draw_shore_corner(sheet, Vector2i(6 + corner, 2), corner)

	_draw_detail(sheet, Vector2i(0, 3), 0)
	_draw_detail(sheet, Vector2i(1, 3), 1)
	_draw_detail(sheet, Vector2i(2, 3), 2)
	_draw_detail(sheet, Vector2i(3, 3), 3)

	var error := sheet.save_png(SHEET_PATH)
	if error != OK:
		_fail("Could not save production sheet", error)
		return
	var preview := _make_preview(sheet)
	error = preview.save_png(PREVIEW_PATH)
	if error != OK:
		_fail("Could not save preview", error)
		return

	error = _save_tileset()
	if error != OK:
		_fail("Could not save TileSet", error)
		return

	print("Generated ", SHEET_PATH, " (256x256)")
	print("Generated ", PREVIEW_PATH, " (", preview.get_width(), "x", preview.get_height(), ")")
	print("Generated ", TILESET_PATH, " with ", TILE_COORDS.size(), " atlas tiles")
	quit(0)


func _origin(tile: Vector2i) -> Vector2i:
	return tile * TILE_SIZE


func _fill_tile(image: Image, tile: Vector2i, color: Color) -> void:
	image.fill_rect(Rect2i(_origin(tile), Vector2i(TILE_SIZE, TILE_SIZE)), color)


func _px(image: Image, tile: Vector2i, x: int, y: int, color: Color) -> void:
	image.set_pixelv(_origin(tile) + Vector2i(x, y), color)


func _rect(image: Image, tile: Vector2i, rect: Rect2i, color: Color) -> void:
	image.fill_rect(Rect2i(_origin(tile) + rect.position, rect.size), color)


func _draw_grass(image: Image, tile: Vector2i, variant: int) -> void:
	_fill_tile(image, tile, P.grass)
	var marks: Array[Vector2i]
	if variant == 1:
		marks = [Vector2i(3, 5), Vector2i(4, 4), Vector2i(11, 12), Vector2i(12, 11)]
	elif variant == 2:
		marks = [Vector2i(2, 13), Vector2i(3, 12), Vector2i(9, 4), Vector2i(10, 5), Vector2i(14, 9)]
	else:
		marks = [Vector2i(6, 9), Vector2i(7, 8)]
	for point: Vector2i in marks:
		_px(image, tile, point.x, point.y, P.grass_dark)
	if variant > 0:
		_px(image, tile, 13 - variant, 3 + variant, P.grass_light)


func _draw_dirt(image: Image, tile: Vector2i, variant: int) -> void:
	_fill_tile(image, tile, P.soil)
	var dark_marks := [Vector2i(2, 4), Vector2i(3, 4), Vector2i(10, 11), Vector2i(11, 11)]
	var light_marks := [Vector2i(7, 7), Vector2i(13, 3)]
	if variant == 1:
		dark_marks = [Vector2i(5, 2), Vector2i(6, 2), Vector2i(12, 9), Vector2i(12, 10)]
		light_marks = [Vector2i(2, 12), Vector2i(9, 6)]
	elif variant == 2:
		dark_marks = [Vector2i(1, 8), Vector2i(2, 8), Vector2i(8, 13), Vector2i(9, 13)]
		light_marks = [Vector2i(6, 4), Vector2i(14, 6)]
	for point: Vector2i in dark_marks:
		_px(image, tile, point.x, point.y, P.soil_dark)
	for point: Vector2i in light_marks:
		_px(image, tile, point.x, point.y, P.soil_light)


func _draw_farm_soil(image: Image, tile: Vector2i, wet: bool, tilled: bool) -> void:
	var base: Color = P.soil_dark if wet else P.soil
	var furrow: Color = P.soil_deep if wet else P.soil_dark
	var ridge: Color = P.soil if wet else P.soil_light
	_fill_tile(image, tile, base)
	if tilled:
		for y: int in [3, 8, 13]:
			_rect(image, tile, Rect2i(0, y, 16, 2), furrow)
			_rect(image, tile, Rect2i(0, y - 1, 16, 1), ridge)
	else:
		for point: Vector2i in [Vector2i(3, 4), Vector2i(11, 3), Vector2i(7, 10), Vector2i(13, 13)]:
			_px(image, tile, point.x, point.y, furrow)


func _draw_tilled_edge(image: Image, tile: Vector2i, horizontal: bool) -> void:
	_draw_farm_soil(image, tile, false, true)
	if horizontal:
		_rect(image, tile, Rect2i(0, 0, 16, 2), P.soil_light)
		_rect(image, tile, Rect2i(0, 2, 16, 1), P.soil_dark)
	else:
		_rect(image, tile, Rect2i(0, 0, 2, 16), P.soil_light)
		_rect(image, tile, Rect2i(2, 0, 1, 16), P.soil_dark)


func _draw_tilled_corner(image: Image, tile: Vector2i, corner: int) -> void:
	_draw_farm_soil(image, tile, false, true)
	var left := corner == 0 or corner == 2
	var top := corner == 0 or corner == 1
	var x := 0 if left else 13
	var y := 0 if top else 13
	_rect(image, tile, Rect2i(x, 0, 3, 16), P.soil_light)
	_rect(image, tile, Rect2i(0, y, 16, 3), P.soil_light)
	_rect(image, tile, Rect2i(x + (2 if left else 0), y + (2 if top else 0), 1, 1), P.soil_dark)


func _draw_path_center(image: Image, tile: Vector2i, variant: bool) -> void:
	_fill_tile(image, tile, P.sand)
	var marks := [Vector2i(3, 5), Vector2i(9, 11), Vector2i(12, 3)] if not variant else [Vector2i(2, 12), Vector2i(7, 4), Vector2i(13, 8)]
	for point: Vector2i in marks:
		_px(image, tile, point.x, point.y, P.sand_dark)
	_px(image, tile, 6 if variant else 13, 14 if variant else 7, P.sand_light)


func _draw_path_edge(image: Image, tile: Vector2i, side: int) -> void:
	_fill_tile(image, tile, P.grass)
	if side == 0:
		_rect(image, tile, Rect2i(0, 4, 16, 12), P.sand)
		_draw_horizontal_bank(image, tile, 4)
	elif side == 1:
		_rect(image, tile, Rect2i(0, 0, 16, 12), P.sand)
		_draw_horizontal_bank(image, tile, 11)
	elif side == 2:
		_rect(image, tile, Rect2i(4, 0, 12, 16), P.sand)
		_draw_vertical_bank(image, tile, 4)
	else:
		_rect(image, tile, Rect2i(0, 0, 12, 16), P.sand)
		_draw_vertical_bank(image, tile, 11)


func _draw_path_corner(image: Image, tile: Vector2i, corner: int, inner: bool) -> void:
	_fill_tile(image, tile, P.sand if inner else P.grass)
	var left := corner == 0 or corner == 2
	var top := corner == 0 or corner == 1
	for y: int in range(16):
		for x: int in range(16):
			var dx := x if left else 15 - x
			var dy := y if top else 15 - y
			var boundary := dx + dy
			if inner and boundary < 7:
				_px(image, tile, x, y, P.grass)
			elif not inner and boundary >= 7:
				_px(image, tile, x, y, P.sand)
	for offset: int in range(3, 12, 4):
		var x := offset if left else 15 - offset
		var y := (7 - offset / 2) if top else (8 + offset / 2)
		_px(image, tile, x, y, P.sand_dark if not inner else P.grass_dark)


func _draw_horizontal_bank(image: Image, tile: Vector2i, y: int) -> void:
	for x: int in range(16):
		var wobble := 1 if x in [3, 10, 11] else 0
		_px(image, tile, x, clampi(y + wobble, 0, 15), P.sand_dark)


func _draw_vertical_bank(image: Image, tile: Vector2i, x: int) -> void:
	for y: int in range(16):
		var wobble := 1 if y in [4, 9, 13] else 0
		_px(image, tile, clampi(x + wobble, 0, 15), y, P.sand_dark)


func _draw_water(image: Image, tile: Vector2i, variant: bool) -> void:
	_fill_tile(image, tile, P.water)
	var y := 5 if variant else 11
	_rect(image, tile, Rect2i(2, y, 5, 1), P.water_light)
	_rect(image, tile, Rect2i(10, 3 if variant else 7, 4, 1), P.water_deep)
	if variant:
		_px(image, tile, 8, 12, P.water_glint)


func _draw_shore_edge(image: Image, tile: Vector2i, side: int) -> void:
	_fill_tile(image, tile, P.grass)
	if side == 0:
		_rect(image, tile, Rect2i(0, 5, 16, 11), P.water)
		_rect(image, tile, Rect2i(0, 3, 16, 2), P.sand)
	elif side == 1:
		_rect(image, tile, Rect2i(0, 0, 16, 11), P.water)
		_rect(image, tile, Rect2i(0, 11, 16, 2), P.sand)
	elif side == 2:
		_rect(image, tile, Rect2i(5, 0, 11, 16), P.water)
		_rect(image, tile, Rect2i(3, 0, 2, 16), P.sand)
	else:
		_rect(image, tile, Rect2i(0, 0, 11, 16), P.water)
		_rect(image, tile, Rect2i(11, 0, 2, 16), P.sand)
	_px(image, tile, 7, 7, P.water_light)


func _draw_shore_corner(image: Image, tile: Vector2i, corner: int) -> void:
	_fill_tile(image, tile, P.water)
	var left := corner == 0 or corner == 2
	var top := corner == 0 or corner == 1
	for y: int in range(16):
		for x: int in range(16):
			var dx := x if left else 15 - x
			var dy := y if top else 15 - y
			if dx + dy < 6:
				_px(image, tile, x, y, P.grass)
			elif dx + dy < 9:
				_px(image, tile, x, y, P.sand)
	_px(image, tile, 9 if left else 6, 9 if top else 6, P.water_light)


func _draw_detail(image: Image, tile: Vector2i, kind: int) -> void:
	image.fill_rect(Rect2i(_origin(tile), Vector2i(16, 16)), Color(0, 0, 0, 0))
	if kind == 0:
		for point: Vector2i in [Vector2i(6, 11), Vector2i(7, 10), Vector2i(7, 9), Vector2i(8, 11), Vector2i(9, 10)]:
			_px(image, tile, point.x, point.y, P.grass_dark)
		_px(image, tile, 7, 8, P.grass_light)
	elif kind == 1:
		for point: Vector2i in [Vector2i(4, 7), Vector2i(5, 7), Vector2i(10, 10), Vector2i(11, 10), Vector2i(8, 4)]:
			_px(image, tile, point.x, point.y, P.soil_dark)
	elif kind == 2:
		_rect(image, tile, Rect2i(4, 9, 4, 2), P.stone_dark)
		_rect(image, tile, Rect2i(5, 8, 3, 2), P.stone)
		_rect(image, tile, Rect2i(10, 5, 2, 2), P.stone)
	else:
		_rect(image, tile, Rect2i(7, 7, 2, 6), P.grass_dark)
		for point: Vector2i in [Vector2i(7, 5), Vector2i(5, 7), Vector2i(9, 7), Vector2i(7, 9)]:
			_px(image, tile, point.x, point.y, P.cream)
		_px(image, tile, 7, 7, P.yellow)


func _make_preview(sheet: Image) -> Image:
	var preview_size := SHEET_SIZE * PREVIEW_SCALE
	var preview := Image.create(preview_size.x, preview_size.y, false, Image.FORMAT_RGBA8)
	preview.fill(Color8(29, 36, 37))
	for source_y: int in range(SHEET_SIZE.y):
		for source_x: int in range(SHEET_SIZE.x):
			var color := sheet.get_pixel(source_x, source_y)
			if color.a > 0.0:
				preview.fill_rect(Rect2i(source_x * PREVIEW_SCALE, source_y * PREVIEW_SCALE, PREVIEW_SCALE, PREVIEW_SCALE), color)
	var grid_color := Color8(104, 122, 112, 110)
	var step := TILE_SIZE * PREVIEW_SCALE
	for x: int in range(0, preview_size.x, step):
		preview.fill_rect(Rect2i(x, 0, 1, preview_size.y), grid_color)
	for y: int in range(0, preview_size.y, step):
		preview.fill_rect(Rect2i(0, y, preview_size.x, 1), grid_color)
	return preview


func _save_tileset() -> Error:
	var texture: Texture2D = load(SHEET_PATH)
	if texture == null:
		printerr("Terrain PNG must be imported before the TileSet can be saved")
		return ERR_CANT_OPEN
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(TILE_SIZE, TILE_SIZE)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = texture
	atlas.texture_region_size = Vector2i(TILE_SIZE, TILE_SIZE)
	for coordinate: Vector2i in TILE_COORDS:
		atlas.create_tile(coordinate)
	tile_set.add_source(atlas, 0)
	var terrain_names := ["Grass", "Path", "Farm Soil", "Water"]
	for set_index: int in range(terrain_names.size()):
		tile_set.add_terrain_set(set_index)
		tile_set.set_terrain_set_mode(set_index, TileSet.TERRAIN_MODE_MATCH_CORNERS_AND_SIDES)
		tile_set.add_terrain(set_index, 0)
		tile_set.set_terrain_name(set_index, 0, terrain_names[set_index])
	var representative_tiles := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(8, 0), Vector2i(0, 2)]
	for set_index: int in range(representative_tiles.size()):
		var tile_data := atlas.get_tile_data(representative_tiles[set_index], 0)
		tile_data.terrain_set = set_index
		tile_data.terrain = 0
	return ResourceSaver.save(tile_set, TILESET_PATH)


func _fail(message: String, error: Error) -> void:
	printerr(message, ": ", error_string(error))
	quit(1)
