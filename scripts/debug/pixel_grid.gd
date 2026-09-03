class_name PixelGrid
extends Node2D

@export_range(1, 64, 1) var cell_size: int = 16
@export var grid_bounds: Rect2 = Rect2(-320.0, -192.0, 1280.0, 768.0)
@export var grid_color: Color = Color(0.92, 0.88, 0.68, 0.12)


func _ready() -> void:
	queue_redraw()


func _draw() -> void:
	var step := float(cell_size)
	var left := floorf(grid_bounds.position.x / step) * step
	var top := floorf(grid_bounds.position.y / step) * step
	var right := ceilf(grid_bounds.end.x / step) * step
	var bottom := ceilf(grid_bounds.end.y / step) * step

	var x := left
	while x <= right:
		draw_line(Vector2(x, top), Vector2(x, bottom), grid_color, 1.0)
		x += step

	var y := top
	while y <= bottom:
		draw_line(Vector2(left, y), Vector2(right, y), grid_color, 1.0)
		y += step
