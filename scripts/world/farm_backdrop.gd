class_name FarmBackdrop
extends Node2D

const GRASS_COLOR := Color("#6eaa62")
const GRASS_DARK := Color("#4f8b55")
const SOIL_COLOR := Color("#a9684f")
const SOIL_DARK := Color("#7d4e46")
const PATH_COLOR := Color("#d6af73")


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	# Overscan lets expanded aspect ratios reveal more world without stretching.
	draw_rect(Rect2(-320.0, -180.0, 1280.0, 720.0), GRASS_COLOR)
	draw_rect(Rect2(-320.0, 304.0, 1280.0, 236.0), Color("#5c985a"))

	var path_points := PackedVector2Array([
		Vector2(262.0, 360.0), Vector2(371.0, 360.0), Vector2(354.0, 310.0),
		Vector2(378.0, 270.0), Vector2(350.0, 235.0), Vector2(365.0, 202.0),
		Vector2(323.0, 190.0), Vector2(298.0, 221.0), Vector2(318.0, 258.0),
		Vector2(289.0, 305.0)
	])
	draw_colored_polygon(path_points, PATH_COLOR)

	draw_rect(Rect2(92.0, 183.0, 188.0, 103.0), SOIL_DARK)
	draw_rect(Rect2(97.0, 178.0, 188.0, 103.0), SOIL_COLOR)
	for row: int in range(3):
		var row_y := 198.0 + float(row) * 30.0
		draw_line(Vector2(107.0, row_y), Vector2(275.0, row_y), Color("#c17e5d"), 2.0)
		draw_line(Vector2(107.0, row_y + 5.0), Vector2(275.0, row_y + 5.0), Color("#925746"), 1.0)

	# Sparse one-pixel marks add texture without relying on production artwork.
	for index: int in range(72):
		var x := float((index * 83 + 17) % 760) - 60.0
		var y := float((index * 47 + 29) % 330) + 8.0
		if Rect2(88.0, 172.0, 205.0, 118.0).has_point(Vector2(x, y)):
			continue
		draw_line(Vector2(x, y), Vector2(x + 1.0, y - 2.0), GRASS_DARK, 1.0)

	# Tiny stepping stones make the path read clearly at the base resolution.
	for stone_position: Vector2 in [Vector2(326.0, 333.0), Vector2(341.0, 286.0), Vector2(334.0, 244.0), Vector2(337.0, 211.0)]:
		draw_circle(stone_position, 4.0, Color("#c59b68"))
		draw_line(stone_position + Vector2(-2.0, -1.0), stone_position + Vector2(2.0, -2.0), Color("#ebca8c"), 1.0)
