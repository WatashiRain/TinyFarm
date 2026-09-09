class_name SonicWave
extends Node2D

var attack: AttackData
var source: Monster
var target: PlayerController
var direction := Vector2.RIGHT
var max_range := 95.0
var width := deg_to_rad(55.0)
var duration := 0.65
var elapsed := 0.0
var hit_target := false


func _ready() -> void:
	add_to_group("sonic_waves")


func configure(pattern: AttackPatternData, owner_node: Monster, target_node: PlayerController) -> void:
	attack = pattern.attack.runtime_copy(pattern.attack.team); source = owner_node; target = target_node
	direction = source.global_position.direction_to(target.global_position)
	max_range = pattern.maximum_distance; width = deg_to_rad(pattern.wave_width_degrees)


func _process(delta: float) -> void:
	elapsed += delta; queue_redraw()
	var radius := max_range * clampf(elapsed / duration, 0.0, 1.0)
	if not hit_target and is_instance_valid(target):
		var offset := target.global_position - global_position
		if absf(offset.length() - radius) <= 9.0 and absf(direction.angle_to(offset.normalized())) <= width * 0.5:
			hit_target = true
			(target.get_node("Hurtbox") as Hurtbox).receive_attack(attack, direction, source)
	if elapsed >= duration: queue_free()


func _draw() -> void:
	var radius := max_range * clampf(elapsed / duration, 0.0, 1.0)
	for offset: float in [0.0, -5.0, -10.0]:
		if radius + offset > 1.0:
			draw_arc(Vector2.ZERO, radius + offset, direction.angle() - width * 0.5, direction.angle() + width * 0.5, 16, Color(0.62, 0.58, 0.95, 0.65 - absf(offset) * 0.035), 2.0)
