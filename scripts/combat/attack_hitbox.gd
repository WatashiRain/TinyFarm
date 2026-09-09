class_name AttackHitbox
extends Area2D

@export var team: StringName = &"player"
var effect_time := 0.0
var effect_direction := Vector2.DOWN
var effect_color := Color("#ffe089")
var effect_range := 26.0


func _process(delta: float) -> void:
	if effect_time > 0.0:
		effect_time -= delta
		queue_redraw()


func activate(direction: Vector2, damage: int, attack_range: float = 26.0, color := Color("#ffe089")) -> int:
	effect_time = 0.14
	effect_direction = direction
	effect_color = color
	effect_range = attack_range
	queue_redraw()
	var center := global_position + direction * 18.0
	var hits := 0
	for hurtbox: Hurtbox in get_tree().get_nodes_in_group("hurtboxes"):
		if hurtbox.team == team or hurtbox.global_position.distance_to(center) > attack_range:
			continue
		hurtbox.receive_hit(damage, direction * 70.0)
		hits += 1
	return hits


func _draw() -> void:
	if effect_time <= 0.0: return
	var side := Vector2(-effect_direction.y, effect_direction.x)
	var center := effect_direction * (effect_range * 0.7)
	var half_width := effect_range * 0.4
	draw_polyline(PackedVector2Array([center - side * half_width, center + effect_direction * effect_range * 0.3, center + side * half_width]), effect_color, 3.0)
