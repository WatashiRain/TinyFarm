class_name AmbientEffect
extends Node2D

enum ParticleKind { LEAF, SPARKLE, DUST, FIREFLY }

@export var particle_kind: ParticleKind = ParticleKind.LEAF
@export_range(1, 16, 1) var particle_count: int = 4
@export var area_size: Vector2 = Vector2(220.0, 120.0)
@export_range(1.0, 20.0, 0.5) var drift_speed: float = 7.0
@export var random_seed: int = 100
@export var particle_color: Color = Color("#e6d77a")
@export var particle_textures: Array[Texture2D] = []

var _positions := PackedVector2Array()
var _phases := PackedFloat32Array()
var _speed_scales := PackedFloat32Array()
var _elapsed: float = 0.0
var _leaf_shape := PackedVector2Array([
	Vector2(-2.0, 0.0), Vector2(0.0, -1.5), Vector2(2.5, 0.0), Vector2(0.0, 1.5)
])


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = random_seed
	_positions.resize(particle_count)
	_phases.resize(particle_count)
	_speed_scales.resize(particle_count)
	for index: int in range(particle_count):
		_positions[index] = Vector2(rng.randf_range(0.0, area_size.x), rng.randf_range(0.0, area_size.y))
		_phases[index] = rng.randf_range(0.0, TAU)
		_speed_scales[index] = rng.randf_range(0.7, 1.25)
	queue_redraw()


func _process(delta: float) -> void:
	_elapsed += delta
	for index: int in range(particle_count):
		var point := _positions[index]
		var speed_scale := _speed_scales[index]
		match particle_kind:
			ParticleKind.LEAF:
				point.x += drift_speed * speed_scale * delta
				point.y += sin(_elapsed * 1.8 + _phases[index]) * 3.0 * delta
			ParticleKind.DUST:
				point.y -= drift_speed * 0.18 * speed_scale * delta
				point.x += sin(_elapsed + _phases[index]) * 0.5 * delta
			ParticleKind.FIREFLY:
				point.x += sin(_elapsed * 0.7 + _phases[index]) * drift_speed * 0.18 * delta
				point.y += cos(_elapsed * 0.9 + _phases[index]) * drift_speed * 0.12 * delta
			ParticleKind.SPARKLE:
				point.y -= drift_speed * 0.04 * delta

		if point.x > area_size.x:
			point.x = 0.0
		elif point.x < 0.0:
			point.x = area_size.x
		if point.y > area_size.y:
			point.y = 0.0
		elif point.y < 0.0:
			point.y = area_size.y
		_positions[index] = point
	queue_redraw()


func _draw() -> void:
	for index: int in range(particle_count):
		var point := _positions[index] - area_size * 0.5
		var pulse := sin(_elapsed * 2.1 + _phases[index]) * 0.5 + 0.5
		match particle_kind:
			ParticleKind.LEAF:
				draw_set_transform(point, sin(_elapsed + _phases[index]) * 0.45)
				var leaf_texture := _particle_texture(index)
				if leaf_texture != null:
					draw_texture(leaf_texture, -leaf_texture.get_size() * 0.5, Color(1.0, 1.0, 1.0, particle_color.a))
				else:
					draw_colored_polygon(_leaf_shape, particle_color)
				draw_set_transform(Vector2.ZERO, 0.0)
			ParticleKind.SPARKLE:
				if pulse > 0.55:
					var sparkle_texture := _particle_texture(index)
					if sparkle_texture != null:
						draw_texture(sparkle_texture, point - sparkle_texture.get_size() * 0.5, Color(1.0, 1.0, 1.0, particle_color.a * pulse))
					else:
						var sparkle_size := 1.0 + pulse * 2.0
						draw_line(point - Vector2(sparkle_size, 0.0), point + Vector2(sparkle_size, 0.0), particle_color, 1.0)
						draw_line(point - Vector2(0.0, sparkle_size), point + Vector2(0.0, sparkle_size), particle_color, 1.0)
			ParticleKind.DUST:
				draw_circle(point, 0.7, Color(particle_color, 0.25 + pulse * 0.3))
			ParticleKind.FIREFLY:
				draw_circle(point, 2.5, Color(particle_color, 0.08 + pulse * 0.12))
				draw_circle(point, 1.0, Color(particle_color, 0.45 + pulse * 0.5))


func _particle_texture(index: int) -> Texture2D:
	if particle_textures.is_empty():
		return null
	return particle_textures[index % particle_textures.size()]
