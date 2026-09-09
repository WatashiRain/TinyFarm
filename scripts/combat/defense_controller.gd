class_name DefenseController
extends Node2D

enum State { IDLE, PARRY, BLOCK, BROKEN }

@export var parry_window := 0.16
@export_range(0.0, 1.0) var block_reduction := 0.65
@export_range(0.1, 1.0) var block_move_multiplier := 0.60
@export var weak_block_cost := 4
@export var strong_block_cost := 8
@export var strong_damage_threshold := 11
@export var break_duration := 0.35

@onready var player: PlayerController = get_parent()
@onready var stats: PlayerStats = player.get_node("Stats")
var state := State.IDLE
var defend_held := false
var state_time := 0.0
var feedback_time := 0.0
var feedback_color := Color.WHITE


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("defend") and not event.is_echo(): begin_defend()
	elif event.is_action_released("defend"): end_defend()


func _process(delta: float) -> void:
	state_time = maxf(0.0, state_time - delta)
	feedback_time = maxf(0.0, feedback_time - delta)
	if state == State.PARRY and state_time <= 0.0:
		state = State.BLOCK if defend_held else State.IDLE
	elif state == State.BROKEN and state_time <= 0.0:
		state = State.BLOCK if defend_held else State.IDLE
	queue_redraw()


func begin_defend() -> void:
	if state == State.BROKEN: return
	defend_held = true
	state = State.PARRY
	state_time = parry_window
	feedback_color = Color("#f8f4c7")
	feedback_time = parry_window
	queue_redraw()


func end_defend() -> void:
	defend_held = false
	if state != State.BROKEN: state = State.IDLE
	queue_redraw()


func movement_multiplier() -> float:
	return block_move_multiplier if state == State.BLOCK else 1.0


func resolve_attack(attack: AttackData, attacker: Node, incoming_direction: Vector2) -> Dictionary:
	if state == State.PARRY and attack.parryable:
		feedback_color = Color("#fff6a5"); feedback_time = 0.22
		player.get_node("Camera2D").shake(0.55, 0.07)
		if attack.reflectable and attacker != null and attacker.has_method("reflect_from"):
			attacker.reflect_from(player)
		elif attacker != null and attacker.has_method("stagger"):
			attacker.stagger(0.45)
		GameState.notify("PARRY")
		return {"outcome": &"parry", "damage": 0}
	if state == State.BLOCK and attack.blockable:
		var energy_cost := strong_block_cost if attack.damage >= strong_damage_threshold else weak_block_cost
		if stats.consume_energy(energy_cost):
			feedback_color = Color("#84cde2"); feedback_time = 0.18
			player.get_node("Camera2D").shake(0.25, 0.05)
			return {"outcome": &"block", "damage": maxi(1, roundi(attack.damage * (1.0 - block_reduction)))}
		state = State.BROKEN; state_time = break_duration
		feedback_color = Color("#ef785f"); feedback_time = break_duration
		player.get_node("Camera2D").shake(0.9, 0.12)
		GameState.notify("BLOCK BREAK")
		return {"outcome": &"block_break", "damage": attack.damage}
	return {"outcome": &"hit", "damage": attack.damage}


func is_parrying() -> bool: return state == State.PARRY
func is_blocking() -> bool: return state == State.BLOCK


func _draw() -> void:
	if state in [State.PARRY, State.BLOCK]:
		var direction: Vector2 = player.get_node("ToolController").facing_vector()
		var center := direction * 12.0
		var start_angle := direction.angle() - 0.9
		draw_arc(center, 10.0, start_angle, start_angle + 1.8, 9, Color("#fff6b2") if state == State.PARRY else Color("#71b8d5"), 2.0)
	if feedback_time > 0.0:
		draw_circle(player.get_node("ToolController").facing_vector() * 13.0, 2.0 + feedback_time * 13.0, Color(feedback_color, minf(1.0, feedback_time * 5.0)), false, 2.0)
