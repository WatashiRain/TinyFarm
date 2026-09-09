class_name CombatProjectile
extends Area2D

enum Mode { STRAIGHT, HOMING }

var attack: AttackData
var team: StringName
var source: Node2D
var target: Node2D
var direction := Vector2.RIGHT
var speed := 70.0
var lifetime := 3.0
var turn_rate := 1.8
var mode := Mode.STRAIGHT
var reflected := false
var pulse_time := 0.0


func _ready() -> void:
	add_to_group("combat_projectiles")
	queue_redraw()


func configure(pattern: AttackPatternData, owner_node: Node2D, target_node: Node2D) -> void:
	attack = pattern.attack.runtime_copy(pattern.attack.team)
	team = attack.team; source = owner_node; target = target_node
	direction = global_position.direction_to(target.global_position)
	speed = pattern.projectile_speed; lifetime = pattern.projectile_lifetime; turn_rate = pattern.homing_turn_rate
	mode = Mode.HOMING if pattern.mode == AttackPatternData.Mode.HOMING_PROJECTILE else Mode.STRAIGHT
	queue_redraw()


func _physics_process(delta: float) -> void:
	if attack == null: return
	lifetime -= delta; pulse_time += delta
	if lifetime <= 0.0: queue_free(); return
	if mode == Mode.HOMING and is_instance_valid(target):
		var desired := global_position.direction_to(target.global_position)
		direction = direction.rotated(clampf(direction.angle_to(desired), -turn_rate * delta, turn_rate * delta)).normalized()
	global_position += direction * speed * delta
	queue_redraw()
	if not is_instance_valid(target): return
	if global_position.distance_to(target.global_position) <= 11.0:
		var hurtbox := target.get_node_or_null("Hurtbox") as Hurtbox
		if hurtbox == null: return
		var outcome := hurtbox.receive_attack(attack, direction, self)
		if outcome != &"parry" and outcome != &"ignored" and outcome != &"invulnerable": queue_free()


func reflect_from(defender: Node) -> void:
	if not attack.reflectable: return
	team = &"player"; attack = attack.runtime_copy(team); reflected = true
	var original_source := source
	source = defender as Node2D
	if is_instance_valid(original_source):
		target = original_source
		direction = global_position.direction_to(target.global_position)
	else:
		target = null
		direction = -direction
	global_position += direction * 12.0
	speed *= 1.2
	queue_redraw()


func _draw() -> void:
	var base := Color("#f4d36d") if reflected else Color("#6de2c2")
	var radius := 6.0 + sin(pulse_time * 10.0) if mode == Mode.HOMING else 3.5
	draw_circle(Vector2.ZERO, radius + 2.0, Color(base, 0.18), true)
	draw_circle(Vector2.ZERO, radius, base, true)
	if reflected: draw_arc(Vector2.ZERO, radius + 2.0, 0, TAU, 12, Color("#fff5a4"), 1.5)
