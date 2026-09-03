class_name InteractionBurst
extends Node2D

@export_range(3, 16, 1) var particle_count: int = 8
@export_range(0.1, 1.0, 0.05) var lifetime: float = 0.38
@export var burst_color: Color = Color("#f8dda0")

var _positions := PackedVector2Array()
var _velocities := PackedVector2Array()
var _age: float = 0.0


func _ready() -> void:
	set_process(false)


func burst() -> void:
	_positions.resize(particle_count)
	_velocities.resize(particle_count)
	for index: int in range(particle_count):
		var angle := -PI + (PI * float(index) / maxf(1.0, float(particle_count - 1)))
		var speed := 20.0 + float(index % 3) * 4.0
		_positions[index] = Vector2.ZERO
		_velocities[index] = Vector2(cos(angle) * speed, sin(angle) * speed - 16.0)
	_age = 0.0
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		set_process(false)
		queue_redraw()
		return
	for index: int in range(particle_count):
		var velocity := _velocities[index]
		velocity.y += 52.0 * delta
		_positions[index] += velocity * delta
		_velocities[index] = velocity
	queue_redraw()


func _draw() -> void:
	if _age >= lifetime or _positions.size() != particle_count:
		return
	var alpha := 1.0 - _age / lifetime
	for index: int in range(particle_count):
		var radius := 1.0 if index % 2 == 0 else 1.5
		draw_circle(_positions[index], radius, Color(burst_color, alpha))
