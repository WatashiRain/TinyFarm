class_name BreezeTree
extends Node2D

const SHARED_SWAY_MATERIAL: ShaderMaterial = preload("res://resources/materials/vegetation_sway.tres")

@export var trunk_texture: Texture2D
@export var foliage_texture: Texture2D
@export var trunk_pixel_offset: Vector2 = Vector2.ZERO
@export var foliage_pixel_offset: Vector2 = Vector2(0.0, -40.0)
@export_range(0.1, 2.0, 0.05) var breeze_amount: float = 0.65
@export_range(1.0, 6.0, 0.1) var breeze_duration: float = 3.2

@onready var foliage: Node2D = $Foliage
@onready var trunk_sprite: Sprite2D = get_node_or_null("TrunkSprite") as Sprite2D
@onready var foliage_sprite: Sprite2D = get_node_or_null("Foliage/FoliageSprite") as Sprite2D


func _ready() -> void:
	_prepare_production_sprites()
	var base_position := foliage.position
	var idle_tween := create_tween().set_loops()
	idle_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	idle_tween.tween_property(foliage, "rotation", deg_to_rad(breeze_amount), breeze_duration)
	idle_tween.parallel().tween_property(foliage, "position", base_position + Vector2(0.6, -0.25), breeze_duration)
	idle_tween.tween_property(foliage, "rotation", deg_to_rad(-breeze_amount * 0.75), breeze_duration * 1.1)
	idle_tween.parallel().tween_property(foliage, "position", base_position + Vector2(-0.45, 0.1), breeze_duration * 1.1)


func _prepare_production_sprites() -> void:
	for child: Node in get_children():
		if child.name in [&"Trunk", &"TrunkLight"] and child is CanvasItem:
			(child as CanvasItem).visible = trunk_texture == null
	for child: Node in foliage.get_children():
		if child is Polygon2D:
			(child as Polygon2D).visible = foliage_texture == null

	if trunk_sprite != null:
		trunk_sprite.texture = trunk_texture
		trunk_sprite.visible = trunk_texture != null
		if trunk_texture != null:
			trunk_sprite.position = Vector2(roundf(trunk_pixel_offset.x), roundf(trunk_pixel_offset.y) - floorf(float(trunk_texture.get_height()) * 0.5))

	if foliage_sprite != null:
		foliage_sprite.texture = foliage_texture
		foliage_sprite.visible = foliage_texture != null
		foliage_sprite.material = SHARED_SWAY_MATERIAL
		if foliage_texture != null:
			foliage_sprite.position = Vector2(roundf(foliage_pixel_offset.x), roundf(foliage_pixel_offset.y) - floorf(float(foliage_texture.get_height()) * 0.5))
