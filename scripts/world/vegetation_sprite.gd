@tool
class_name VegetationSprite
extends Node2D

const SWAY_SHADER: Shader = preload("res://shaders/vegetation_sway.gdshader")
const SHARED_SWAY_MATERIAL: ShaderMaterial = preload("res://resources/materials/vegetation_sway.tres")

var _custom_material: ShaderMaterial

@export var texture: Texture2D:
	set(value):
		texture = value
		_refresh_visual()
@export var horizontal_flip: bool = false:
	set(value):
		horizontal_flip = value
		_refresh_visual()
@export var pixel_offset: Vector2 = Vector2.ZERO:
	set(value):
		pixel_offset = value
		_refresh_visual()

@export_group("Optional Sway Override")
@export var use_custom_sway: bool = false:
	set(value):
		use_custom_sway = value
		_refresh_visual()
@export_range(0.0, 5.0, 0.1) var sway_strength: float = 1.5:
	set(value):
		sway_strength = value
		_refresh_visual()
@export_range(0.1, 4.0, 0.05) var sway_speed: float = 1.2:
	set(value):
		sway_speed = value
		_refresh_visual()
@export_range(0.0, 6.283, 0.01) var phase_offset: float = 0.0:
	set(value):
		phase_offset = value
		_refresh_visual()


func _ready() -> void:
	_refresh_visual()


func _refresh_visual() -> void:
	var sprite := get_node_or_null("Sprite") as Sprite2D
	if sprite == null:
		return

	sprite.texture = texture
	sprite.flip_h = horizontal_flip
	var anchored_position := Vector2(roundf(pixel_offset.x), roundf(pixel_offset.y))
	if texture != null:
		anchored_position.y -= floorf(float(texture.get_height()) * 0.5)
	sprite.position = anchored_position

	if not use_custom_sway:
		sprite.material = SHARED_SWAY_MATERIAL
		return

	if _custom_material == null:
		_custom_material = ShaderMaterial.new()
		_custom_material.shader = SWAY_SHADER
	_custom_material.set_shader_parameter("sway_strength", sway_strength)
	_custom_material.set_shader_parameter("sway_speed", sway_speed)
	_custom_material.set_shader_parameter("phase_offset", phase_offset)
	_custom_material.set_shader_parameter("use_world_position_phase", false)
	sprite.material = _custom_material
