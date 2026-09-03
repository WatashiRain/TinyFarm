class_name WorldDecoration
extends Node2D

enum DecorationKind { ROCK, FLOWER }
const SHARED_SWAY_MATERIAL: ShaderMaterial = preload("res://resources/materials/vegetation_sway.tres")

@export var decoration_kind: DecorationKind = DecorationKind.ROCK
@export var variant: int = 0
@export var primary_color: Color = Color("#738078")
@export var sprite_texture: Texture2D
@export var horizontal_flip: bool = false
@export var pixel_offset: Vector2 = Vector2.ZERO

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	sprite.texture = sprite_texture
	sprite.visible = sprite_texture != null
	sprite.flip_h = horizontal_flip
	if sprite_texture != null:
		sprite.position = Vector2(roundf(pixel_offset.x), roundf(pixel_offset.y) - floorf(float(sprite_texture.get_height()) * 0.5))
		sprite.material = SHARED_SWAY_MATERIAL if decoration_kind == DecorationKind.FLOWER else null
	queue_redraw()


func _draw() -> void:
	if sprite_texture != null:
		return
	if decoration_kind == DecorationKind.ROCK:
		_draw_rock()
	else:
		_draw_flower()


func _draw_rock() -> void:
	var width := 7.0 + float(variant % 3) * 2.0
	var rock := PackedVector2Array([
		Vector2(-width, 0.0), Vector2(-width + 2.0, -6.0), Vector2(-2.0, -9.0),
		Vector2(width - 2.0, -7.0), Vector2(width, -2.0), Vector2(width - 2.0, 1.0)
	])
	draw_colored_polygon(rock, primary_color)
	draw_line(Vector2(-width + 2.0, -5.0), Vector2(-1.0, -7.0), primary_color.lightened(0.25), 2.0)
	draw_line(Vector2(-width, 0.0), Vector2(width - 2.0, 1.0), primary_color.darkened(0.25), 2.0)


func _draw_flower() -> void:
	var petal_color := primary_color
	var center_color := Color("#ffd37a")
	draw_line(Vector2.ZERO, Vector2(0.0, -9.0), Color("#397a4b"), 2.0)
	for direction: Vector2 in [Vector2(-3.0, 0.0), Vector2(3.0, 0.0), Vector2(0.0, -3.0), Vector2(0.0, 3.0)]:
		draw_circle(Vector2(0.0, -10.0) + direction, 2.25, petal_color)
	draw_circle(Vector2(0.0, -10.0), 2.0, center_color)
