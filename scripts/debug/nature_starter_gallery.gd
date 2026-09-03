extends Node2D

const GRID_ORIGIN := Vector2(32.0, 80.0)
const DISPLAY_SCALE := 4.0
const CELL_SIZE := 16.0 * DISPLAY_SCALE
const GRID_COLUMNS := 9
const GRID_ROWS := 3


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(640.0, 360.0)), Color("#1d2526"))
	var grid_color := Color(0.48, 0.58, 0.52, 0.26)
	for column: int in range(GRID_COLUMNS + 1):
		var x := GRID_ORIGIN.x + float(column) * CELL_SIZE
		draw_line(Vector2(x, GRID_ORIGIN.y), Vector2(x, GRID_ORIGIN.y + float(GRID_ROWS) * CELL_SIZE), grid_color, 1.0)
	for row: int in range(GRID_ROWS + 1):
		var y := GRID_ORIGIN.y + float(row) * CELL_SIZE
		draw_line(Vector2(GRID_ORIGIN.x, y), Vector2(GRID_ORIGIN.x + float(GRID_COLUMNS) * CELL_SIZE, y), grid_color, 1.0)
