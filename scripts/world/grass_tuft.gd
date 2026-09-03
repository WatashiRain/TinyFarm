class_name GrassTuft
extends Node2D

const SWAY_SHADER: Shader = preload("res://shaders/vegetation_sway.gdshader")
const SHARED_SWAY_MATERIAL: ShaderMaterial = preload("res://resources/materials/vegetation_sway.tres")

@export var sprite_texture: Texture2D
@export var tuft_color: Color = Color("#397a4b")
@export_range(5.0, 24.0, 1.0) var tuft_height: float = 13.0
@export_range(4.0, 20.0, 1.0) var tuft_width: float = 10.0
@export_range(0.0, 5.0, 0.1) var sway_strength: float = 1.5
@export_range(0.1, 4.0, 0.05) var sway_speed: float = 1.2
@export_range(-1.0, 6.283, 0.01) var phase_offset: float = -1.0
@export var random_seed: int = 1
@export var allow_horizontal_flip: bool = true
@export var pixel_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed

	var visual := Node2D.new()
	visual.position = Vector2(roundf(pixel_offset.x), roundf(pixel_offset.y))
	if sprite_texture == null:
		visual.position += Vector2(rng.randf_range(-1.5, 1.5), rng.randf_range(-0.75, 0.75))
	if allow_horizontal_flip and rng.randf() > 0.5:
		visual.scale.x = -1.0
	add_child(visual)

	if sprite_texture != null:
		_add_sprite_visual(visual)
		return

	var sway_material := ShaderMaterial.new()
	sway_material.shader = SWAY_SHADER
	sway_material.set_shader_parameter("sway_strength", sway_strength * rng.randf_range(0.82, 1.18))
	sway_material.set_shader_parameter("sway_speed", sway_speed * rng.randf_range(0.9, 1.1))
	sway_material.set_shader_parameter("phase_offset", rng.randf_range(0.0, TAU))

	_add_blade(visual, sway_material, -tuft_width * 0.42, tuft_height * 0.72, -2.0)
	_add_blade(visual, sway_material, 0.0, tuft_height, 0.5)
	_add_blade(visual, sway_material, tuft_width * 0.42, tuft_height * 0.78, 2.0)


func _add_blade(parent: Node2D, sway_material: ShaderMaterial, x_offset: float, blade_height: float, lean: float) -> void:
	var blade := Polygon2D.new()
	var half_width := maxf(1.2, tuft_width * 0.14)
	blade.polygon = PackedVector2Array([
		Vector2(x_offset - half_width, 0.0),
		Vector2(x_offset + half_width, 0.0),
		Vector2(x_offset + lean + 0.8, -blade_height + 2.0),
		Vector2(x_offset + lean, -blade_height)
	])
	blade.uv = PackedVector2Array([
		Vector2(0.0, 1.0), Vector2(1.0, 1.0), Vector2(1.0, 0.0), Vector2(0.0, 0.0)
	])
	blade.color = tuft_color
	blade.material = sway_material
	parent.add_child(blade)


func _add_sprite_visual(parent: Node2D) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = sprite_texture
	sprite.position.y = -floorf(float(sprite_texture.get_height()) * 0.5)

	if phase_offset < 0.0 and is_equal_approx(sway_strength, 1.5) and is_equal_approx(sway_speed, 1.2):
		sprite.material = SHARED_SWAY_MATERIAL
	else:
		var custom_material := ShaderMaterial.new()
		custom_material.shader = SWAY_SHADER
		custom_material.set_shader_parameter("sway_strength", sway_strength)
		custom_material.set_shader_parameter("sway_speed", sway_speed)
		custom_material.set_shader_parameter("phase_offset", maxf(phase_offset, 0.0))
		custom_material.set_shader_parameter("use_world_position_phase", phase_offset < 0.0)
		sprite.material = custom_material
	parent.add_child(sprite)
