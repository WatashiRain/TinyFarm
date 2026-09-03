extends SceneTree

const SHEET_SIZE := Vector2i(256, 64)
const PREVIEW_SCALE := 8
const SHEET_PATH := "res://art/environment/nature/nature_starter_v01.png"
const PREVIEW_PATH := "res://art/environment/nature/nature_starter_v01_preview.png"

const P := {
	"outline_deep": Color8(31, 57, 53),
	"outline_soft": Color8(43, 74, 64),
	"foliage_deepest": Color8(40, 75, 58),
	"foliage_shadow": Color8(53, 99, 66),
	"foliage_dark": Color8(63, 117, 71),
	"foliage_mid": Color8(82, 145, 79),
	"foliage_light": Color8(112, 173, 92),
	"foliage_highlight": Color8(145, 201, 104),
	"foliage_gold": Color8(159, 186, 88),
	"soil_deep": Color8(94, 59, 53),
	"bark_dark": Color8(112, 69, 56),
	"bark_mid": Color8(150, 91, 66),
	"bark_light": Color8(188, 118, 80),
	"wood_cut": Color8(210, 164, 101),
	"wood_light": Color8(231, 201, 132),
	"soil_mid": Color8(167, 106, 80),
	"soil_light": Color8(201, 133, 96),
	"stone_outline": Color8(66, 87, 82),
	"stone_dark": Color8(96, 113, 106),
	"stone_mid": Color8(126, 142, 131),
	"stone_light": Color8(167, 178, 159),
	"cream": Color8(242, 230, 188),
	"cream_shadow": Color8(220, 203, 155),
	"yellow": Color8(231, 185, 76),
	"yellow_light": Color8(247, 217, 120),
	"pink": Color8(231, 140, 154),
	"pink_light": Color8(243, 179, 176),
	"mushroom_red": Color8(201, 79, 73),
	"mushroom_light": Color8(228, 116, 94),
	"golden_leaf": Color8(215, 158, 62),
	"sparkle": Color8(255, 240, 176),
}


func _initialize() -> void:
	call_deferred("_generate")


func _generate() -> void:
	var sheet := Image.create(SHEET_SIZE.x, SHEET_SIZE.y, false, Image.FORMAT_RGBA8)
	sheet.fill(Color(0.0, 0.0, 0.0, 0.0))

	_draw_grass_01(sheet, Vector2i(0, 0))
	_draw_grass_02(sheet, Vector2i(16, 0))
	_draw_grass_03(sheet, Vector2i(32, 0))
	_draw_flower_white(sheet, Vector2i(48, 0))
	_draw_flower_yellow(sheet, Vector2i(64, 0))
	_draw_flower_pink(sheet, Vector2i(80, 0))
	_draw_rock_01(sheet, Vector2i(96, 0))
	_draw_rock_02(sheet, Vector2i(112, 0))
	_draw_rock_03(sheet, Vector2i(128, 0))
	_draw_stump(sheet, Vector2i(144, 0))
	_draw_mushroom(sheet, Vector2i(160, 0))
	_draw_leaf_01(sheet, Vector2i(176, 0))
	_draw_leaf_02(sheet, Vector2i(192, 0))
	_draw_sparkle_01(sheet, Vector2i(208, 0))
	_draw_sparkle_02(sheet, Vector2i(224, 0))
	_draw_bush_01(sheet, Vector2i(0, 16))
	_draw_bush_02(sheet, Vector2i(32, 16))

	var error := sheet.save_png(SHEET_PATH)
	if error != OK:
		printerr("Could not save production sheet: ", error_string(error))
		quit(1)
		return

	var preview := _make_preview(sheet)
	error = preview.save_png(PREVIEW_PATH)
	if error != OK:
		printerr("Could not save preview: ", error_string(error))
		quit(1)
		return

	print("Generated ", SHEET_PATH, " (", SHEET_SIZE.x, "x", SHEET_SIZE.y, ")")
	print("Generated ", PREVIEW_PATH, " (", preview.get_width(), "x", preview.get_height(), ")")
	quit(0)


func _px(image: Image, origin: Vector2i, x: int, y: int, color: Color) -> void:
	image.set_pixelv(origin + Vector2i(x, y), color)


func _pixels(image: Image, origin: Vector2i, points: Array, color: Color) -> void:
	for point: Vector2i in points:
		image.set_pixelv(origin + point, color)


func _rect(image: Image, origin: Vector2i, rect: Rect2i, color: Color) -> void:
	image.fill_rect(Rect2i(origin + rect.position, rect.size), color)


func _span(image: Image, origin: Vector2i, y: int, left: int, right: int, color: Color) -> void:
	image.fill_rect(Rect2i(origin + Vector2i(left, y), Vector2i(right - left + 1, 1)), color)


func _draw_grass_01(image: Image, origin: Vector2i) -> void:
	_span(image, origin, 15, 5, 10, P.outline_deep)
	_pixels(image, origin, [Vector2i(6, 14), Vector2i(6, 13), Vector2i(6, 12), Vector2i(5, 11), Vector2i(7, 14), Vector2i(7, 13), Vector2i(7, 12), Vector2i(7, 11), Vector2i(7, 10), Vector2i(7, 9), Vector2i(7, 8), Vector2i(8, 7), Vector2i(8, 6), Vector2i(9, 14), Vector2i(9, 13), Vector2i(10, 12), Vector2i(10, 11)], P.foliage_dark)
	_pixels(image, origin, [Vector2i(8, 14), Vector2i(8, 13), Vector2i(8, 12), Vector2i(8, 11), Vector2i(8, 10), Vector2i(8, 9), Vector2i(9, 12), Vector2i(9, 11)], P.foliage_light)
	_pixels(image, origin, [Vector2i(5, 10), Vector2i(8, 5), Vector2i(10, 10)], P.foliage_highlight)


func _draw_grass_02(image: Image, origin: Vector2i) -> void:
	_span(image, origin, 15, 2, 13, P.outline_deep)
	_pixels(image, origin, [Vector2i(3, 14), Vector2i(3, 13), Vector2i(2, 12), Vector2i(2, 11), Vector2i(5, 14), Vector2i(5, 13), Vector2i(4, 12), Vector2i(4, 11), Vector2i(4, 10), Vector2i(7, 14), Vector2i(7, 13), Vector2i(7, 12), Vector2i(7, 11), Vector2i(7, 10), Vector2i(9, 14), Vector2i(9, 13), Vector2i(10, 12), Vector2i(10, 11), Vector2i(11, 10), Vector2i(12, 14), Vector2i(12, 13), Vector2i(13, 12), Vector2i(13, 11)], P.foliage_dark)
	_pixels(image, origin, [Vector2i(3, 12), Vector2i(4, 13), Vector2i(5, 12), Vector2i(6, 13), Vector2i(6, 12), Vector2i(8, 13), Vector2i(8, 12), Vector2i(9, 12), Vector2i(10, 13), Vector2i(11, 12), Vector2i(12, 12)], P.foliage_light)
	_pixels(image, origin, [Vector2i(2, 10), Vector2i(4, 9), Vector2i(7, 9), Vector2i(11, 9), Vector2i(13, 10)], P.foliage_highlight)


func _draw_grass_03(image: Image, origin: Vector2i) -> void:
	_span(image, origin, 15, 4, 12, P.outline_deep)
	_pixels(image, origin, [Vector2i(5, 14), Vector2i(5, 13), Vector2i(4, 12), Vector2i(4, 11), Vector2i(5, 10), Vector2i(6, 9), Vector2i(7, 8), Vector2i(8, 7), Vector2i(9, 6), Vector2i(10, 5), Vector2i(11, 4), Vector2i(11, 3), Vector2i(8, 14), Vector2i(8, 13), Vector2i(8, 12), Vector2i(8, 11), Vector2i(9, 10), Vector2i(10, 9), Vector2i(11, 8), Vector2i(11, 14), Vector2i(11, 13), Vector2i(12, 12), Vector2i(13, 11)], P.foliage_dark)
	_pixels(image, origin, [Vector2i(6, 14), Vector2i(6, 13), Vector2i(6, 12), Vector2i(6, 11), Vector2i(7, 13), Vector2i(7, 12), Vector2i(7, 11), Vector2i(9, 13), Vector2i(9, 12), Vector2i(9, 11), Vector2i(10, 12), Vector2i(10, 11), Vector2i(11, 10), Vector2i(12, 11)], P.foliage_light)
	_pixels(image, origin, [Vector2i(7, 7), Vector2i(10, 4), Vector2i(11, 2), Vector2i(13, 10)], P.foliage_highlight)


func _draw_stem(image: Image, origin: Vector2i) -> void:
	_pixels(image, origin, [Vector2i(7, 15), Vector2i(8, 15), Vector2i(7, 14), Vector2i(7, 13), Vector2i(7, 12), Vector2i(7, 11), Vector2i(6, 13), Vector2i(5, 12), Vector2i(8, 12), Vector2i(9, 11)], P.foliage_dark)
	_pixels(image, origin, [Vector2i(8, 14), Vector2i(8, 13), Vector2i(6, 12), Vector2i(9, 10)], P.foliage_light)


func _draw_flower_white(image: Image, origin: Vector2i) -> void:
	_draw_stem(image, origin)
	_pixels(image, origin, [Vector2i(7, 3), Vector2i(4, 6), Vector2i(10, 6), Vector2i(4, 8), Vector2i(10, 8), Vector2i(7, 10)], P.outline_soft)
	_pixels(image, origin, [Vector2i(7, 5), Vector2i(6, 6), Vector2i(8, 6), Vector2i(5, 7), Vector2i(9, 7), Vector2i(6, 8), Vector2i(8, 8)], P.cream_shadow)
	_pixels(image, origin, [Vector2i(7, 4), Vector2i(5, 6), Vector2i(9, 6), Vector2i(5, 8), Vector2i(9, 8), Vector2i(7, 9)], P.cream)
	_rect(image, origin, Rect2i(7, 6, 2, 2), P.yellow)
	_px(image, origin, 7, 6, P.yellow_light)


func _draw_flower_yellow(image: Image, origin: Vector2i) -> void:
	_draw_stem(image, origin)
	_pixels(image, origin, [Vector2i(6, 3), Vector2i(8, 3), Vector2i(3, 6), Vector2i(11, 6), Vector2i(7, 10)], P.outline_soft)
	_pixels(image, origin, [Vector2i(6, 5), Vector2i(7, 5), Vector2i(8, 5), Vector2i(5, 6), Vector2i(9, 6), Vector2i(5, 7), Vector2i(9, 7), Vector2i(6, 8), Vector2i(8, 8)], P.golden_leaf)
	_pixels(image, origin, [Vector2i(6, 4), Vector2i(8, 4), Vector2i(4, 6), Vector2i(10, 6), Vector2i(7, 9)], P.yellow)
	_rect(image, origin, Rect2i(6, 6, 3, 2), P.yellow_light)
	_px(image, origin, 7, 7, P.bark_mid)


func _draw_flower_pink(image: Image, origin: Vector2i) -> void:
	_draw_stem(image, origin)
	_pixels(image, origin, [Vector2i(6, 3), Vector2i(7, 3), Vector2i(8, 3), Vector2i(9, 3), Vector2i(4, 5), Vector2i(11, 5), Vector2i(4, 8), Vector2i(11, 8), Vector2i(6, 10), Vector2i(9, 10)], P.outline_soft)
	_rect(image, origin, Rect2i(5, 5, 2, 3), P.pink)
	_rect(image, origin, Rect2i(9, 5, 2, 3), P.pink)
	_rect(image, origin, Rect2i(6, 4, 4, 2), P.pink_light)
	_rect(image, origin, Rect2i(6, 8, 4, 2), P.pink)
	_rect(image, origin, Rect2i(7, 6, 2, 2), P.yellow_light)


func _draw_rock_01(image: Image, origin: Vector2i) -> void:
	_span(image, origin, 9, 5, 10, P.stone_outline)
	_span(image, origin, 10, 3, 12, P.stone_outline)
	_span(image, origin, 11, 2, 13, P.stone_outline)
	_span(image, origin, 12, 2, 13, P.stone_dark)
	_span(image, origin, 13, 2, 13, P.stone_mid)
	_span(image, origin, 14, 3, 12, P.stone_outline)
	_span(image, origin, 15, 5, 10, P.stone_outline)
	_rect(image, origin, Rect2i(5, 10, 5, 2), P.stone_mid)
	_pixels(image, origin, [Vector2i(6, 9), Vector2i(7, 9), Vector2i(8, 9), Vector2i(4, 11), Vector2i(5, 11), Vector2i(6, 11)], P.stone_light)


func _draw_rock_02(image: Image, origin: Vector2i) -> void:
	_pixels(image, origin, [Vector2i(5, 7), Vector2i(6, 7), Vector2i(7, 7), Vector2i(8, 7), Vector2i(4, 8), Vector2i(9, 8), Vector2i(10, 8), Vector2i(3, 9), Vector2i(11, 9)], P.stone_outline)
	_span(image, origin, 10, 2, 12, P.stone_outline)
	_span(image, origin, 11, 2, 13, P.stone_dark)
	_span(image, origin, 12, 2, 13, P.stone_mid)
	_span(image, origin, 13, 3, 12, P.stone_mid)
	_span(image, origin, 14, 3, 12, P.stone_outline)
	_span(image, origin, 15, 5, 10, P.stone_outline)
	_pixels(image, origin, [Vector2i(6, 8), Vector2i(7, 8), Vector2i(8, 8), Vector2i(5, 9), Vector2i(6, 9), Vector2i(7, 9), Vector2i(4, 10), Vector2i(5, 10)], P.stone_light)
	_pixels(image, origin, [Vector2i(10, 10), Vector2i(11, 11), Vector2i(10, 12)], P.stone_dark)


func _draw_rock_03(image: Image, origin: Vector2i) -> void:
	_span(image, origin, 10, 4, 11, P.stone_outline)
	_span(image, origin, 11, 2, 13, P.stone_outline)
	_span(image, origin, 12, 1, 14, P.stone_dark)
	_span(image, origin, 13, 1, 14, P.stone_mid)
	_span(image, origin, 14, 2, 13, P.stone_outline)
	_span(image, origin, 15, 4, 11, P.stone_outline)
	_rect(image, origin, Rect2i(4, 11, 6, 2), P.stone_mid)
	_pixels(image, origin, [Vector2i(5, 10), Vector2i(6, 10), Vector2i(7, 10), Vector2i(3, 11), Vector2i(4, 11), Vector2i(5, 11)], P.stone_light)


func _draw_stump(image: Image, origin: Vector2i) -> void:
	_span(image, origin, 7, 5, 10, P.bark_dark)
	_span(image, origin, 8, 3, 12, P.bark_dark)
	_span(image, origin, 9, 3, 12, P.wood_cut)
	_span(image, origin, 10, 4, 11, P.wood_light)
	_rect(image, origin, Rect2i(4, 11, 8, 4), P.bark_mid)
	_pixels(image, origin, [Vector2i(3, 12), Vector2i(2, 13), Vector2i(3, 14), Vector2i(12, 12), Vector2i(13, 13), Vector2i(12, 14)], P.bark_dark)
	_span(image, origin, 15, 2, 13, P.soil_deep)
	_pixels(image, origin, [Vector2i(6, 9), Vector2i(7, 9), Vector2i(8, 10), Vector2i(9, 9), Vector2i(10, 9)], P.bark_light)
	_pixels(image, origin, [Vector2i(6, 12), Vector2i(6, 13), Vector2i(9, 11), Vector2i(9, 12), Vector2i(10, 13)], P.bark_light)


func _draw_mushroom(image: Image, origin: Vector2i) -> void:
	_span(image, origin, 7, 6, 9, P.outline_deep)
	_span(image, origin, 8, 4, 11, P.outline_deep)
	_span(image, origin, 9, 3, 12, P.mushroom_red)
	_span(image, origin, 10, 4, 11, P.mushroom_light)
	_span(image, origin, 11, 5, 10, P.outline_deep)
	_rect(image, origin, Rect2i(7, 11, 2, 4), P.cream_shadow)
	_pixels(image, origin, [Vector2i(6, 14), Vector2i(7, 14), Vector2i(8, 14), Vector2i(9, 14)], P.cream)
	_pixels(image, origin, [Vector2i(6, 8), Vector2i(9, 8), Vector2i(10, 9)], P.cream)
	_span(image, origin, 15, 5, 10, P.outline_soft)


func _draw_leaf_01(image: Image, origin: Vector2i) -> void:
	_pixels(image, origin, [Vector2i(7, 7), Vector2i(8, 7), Vector2i(6, 8), Vector2i(7, 8), Vector2i(8, 8), Vector2i(7, 9)], P.golden_leaf)
	_pixels(image, origin, [Vector2i(9, 7), Vector2i(8, 9)], P.foliage_gold)


func _draw_leaf_02(image: Image, origin: Vector2i) -> void:
	_pixels(image, origin, [Vector2i(7, 6), Vector2i(7, 7), Vector2i(8, 7), Vector2i(8, 8), Vector2i(9, 8), Vector2i(9, 9)], P.foliage_light)
	_pixels(image, origin, [Vector2i(6, 6), Vector2i(8, 9)], P.foliage_dark)


func _draw_sparkle_01(image: Image, origin: Vector2i) -> void:
	_pixels(image, origin, [Vector2i(7, 7), Vector2i(8, 7), Vector2i(7, 8), Vector2i(8, 8)], P.sparkle)
	_px(image, origin, 9, 8, P.yellow_light)


func _draw_sparkle_02(image: Image, origin: Vector2i) -> void:
	_pixels(image, origin, [Vector2i(7, 5), Vector2i(7, 6), Vector2i(5, 7), Vector2i(6, 7), Vector2i(7, 7), Vector2i(8, 7), Vector2i(9, 7), Vector2i(7, 8), Vector2i(7, 9)], P.sparkle)
	_pixels(image, origin, [Vector2i(6, 6), Vector2i(8, 6), Vector2i(6, 8), Vector2i(8, 8)], P.yellow_light)


func _draw_bush_01(image: Image, origin: Vector2i) -> void:
	var silhouette := [
		[8, 13, 18], [9, 10, 21], [10, 9, 23], [11, 7, 24], [12, 6, 26],
		[13, 4, 27], [14, 4, 29], [15, 2, 29], [16, 2, 30], [17, 1, 30],
		[18, 2, 30], [19, 1, 29], [20, 2, 29], [21, 3, 28], [22, 3, 29],
		[23, 4, 27], [24, 5, 26], [25, 6, 25], [26, 8, 24], [27, 10, 22], [28, 12, 20]
	]
	for span: Array in silhouette:
		_span(image, origin, span[0], span[1], span[2], P.foliage_deepest)
	for y: int in range(12, 26):
		var inset := 1 if y < 15 or y > 22 else 0
		_span(image, origin, y, 5 + inset, 26 - inset, P.foliage_shadow)
	# Interlocking clusters share one silhouette, so the bush reads as foliage instead of stacked balls.
	_span(image, origin, 11, 11, 19, P.foliage_light)
	_span(image, origin, 12, 9, 20, P.foliage_light)
	_span(image, origin, 13, 8, 19, P.foliage_mid)
	_span(image, origin, 14, 6, 14, P.foliage_mid)
	_span(image, origin, 15, 5, 13, P.foliage_mid)
	_span(image, origin, 14, 20, 26, P.foliage_mid)
	_span(image, origin, 15, 19, 27, P.foliage_mid)
	_span(image, origin, 17, 11, 23, P.foliage_light)
	_span(image, origin, 18, 9, 22, P.foliage_light)
	_span(image, origin, 19, 7, 16, P.foliage_mid)
	_span(image, origin, 20, 6, 15, P.foliage_mid)
	_span(image, origin, 21, 17, 25, P.foliage_mid)
	_span(image, origin, 22, 16, 24, P.foliage_mid)
	_pixels(image, origin, [Vector2i(12, 10), Vector2i(16, 10), Vector2i(7, 13), Vector2i(23, 13), Vector2i(13, 17), Vector2i(19, 17), Vector2i(8, 19), Vector2i(20, 21)], P.foliage_highlight)
	_pixels(image, origin, [Vector2i(3, 16), Vector2i(28, 14), Vector2i(2, 20), Vector2i(27, 23), Vector2i(10, 25), Vector2i(23, 25)], P.foliage_dark)
	_span(image, origin, 27, 10, 22, P.outline_soft)
	_span(image, origin, 28, 12, 20, P.outline_deep)


func _draw_bush_02(image: Image, origin: Vector2i) -> void:
	var silhouette := [
		[10, 9, 15], [11, 7, 19], [12, 5, 22], [13, 4, 25], [14, 2, 27],
		[15, 2, 29], [16, 1, 30], [17, 1, 30], [18, 2, 31], [19, 1, 30],
		[20, 2, 30], [21, 3, 29], [22, 3, 29], [23, 4, 28], [24, 5, 27],
		[25, 6, 26], [26, 8, 25], [27, 10, 23], [28, 13, 21]
	]
	for span: Array in silhouette:
		_span(image, origin, span[0], span[1], span[2], P.foliage_deepest)
	for y: int in range(14, 26):
		_span(image, origin, y, 4, 28, P.foliage_shadow)
	_span(image, origin, 12, 9, 17, P.foliage_light)
	_span(image, origin, 13, 7, 18, P.foliage_light)
	_span(image, origin, 14, 6, 16, P.foliage_mid)
	_span(image, origin, 15, 4, 13, P.foliage_mid)
	_span(image, origin, 14, 19, 25, P.foliage_mid)
	_span(image, origin, 15, 17, 27, P.foliage_mid)
	_span(image, origin, 16, 20, 29, P.foliage_light)
	_span(image, origin, 18, 9, 21, P.foliage_light)
	_span(image, origin, 19, 7, 19, P.foliage_light)
	_span(image, origin, 20, 5, 14, P.foliage_mid)
	_span(image, origin, 21, 4, 13, P.foliage_mid)
	_span(image, origin, 21, 16, 26, P.foliage_mid)
	_span(image, origin, 22, 15, 25, P.foliage_mid)
	_pixels(image, origin, [Vector2i(10, 11), Vector2i(14, 11), Vector2i(7, 13), Vector2i(22, 13), Vector2i(25, 15), Vector2i(11, 18), Vector2i(18, 18), Vector2i(7, 20), Vector2i(20, 21)], P.foliage_highlight)
	_pixels(image, origin, [Vector2i(2, 15), Vector2i(29, 16), Vector2i(1, 19), Vector2i(28, 23), Vector2i(8, 25), Vector2i(24, 25)], P.foliage_dark)
	_span(image, origin, 27, 10, 23, P.outline_soft)
	_span(image, origin, 28, 13, 21, P.outline_deep)


func _make_preview(sheet: Image) -> Image:
	var preview_size := SHEET_SIZE * PREVIEW_SCALE
	var preview := Image.create(preview_size.x, preview_size.y, false, Image.FORMAT_RGBA8)
	preview.fill(Color8(29, 36, 37))

	for source_y: int in range(SHEET_SIZE.y):
		for source_x: int in range(SHEET_SIZE.x):
			var color := sheet.get_pixel(source_x, source_y)
			if color.a > 0.0:
				preview.fill_rect(
					Rect2i(source_x * PREVIEW_SCALE, source_y * PREVIEW_SCALE, PREVIEW_SCALE, PREVIEW_SCALE),
					color
				)

	var grid_color := Color8(104, 122, 112, 120)
	var cell_step := 16 * PREVIEW_SCALE
	for x: int in range(0, preview_size.x + 1, cell_step):
		if x < preview_size.x:
			preview.fill_rect(Rect2i(x, 0, 1, preview_size.y), grid_color)
	for y: int in range(0, preview_size.y + 1, cell_step):
		if y < preview_size.y:
			preview.fill_rect(Rect2i(0, y, preview_size.x, 1), grid_color)
	return preview
