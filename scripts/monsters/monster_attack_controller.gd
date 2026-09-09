class_name MonsterAttackController
extends Node2D

const PROJECTILE_SCENE := preload("res://scenes/projectiles/combat_projectile.tscn")
const SONIC_SCENE := preload("res://scenes/projectiles/sonic_wave.tscn")

@onready var monster: Monster = get_parent()
@onready var telegraph: AttackTelegraph = $Telegraph
var patterns: Array[AttackPatternData] = []
var busy := false
var cooldown_remaining := 0.45
var current_pattern: AttackPatternData


func _ready() -> void:
	patterns = monster.data.attack_patterns


func _process(delta: float) -> void:
	cooldown_remaining = maxf(0.0, cooldown_remaining - delta)


func try_attack(distance: float) -> bool:
	if busy or cooldown_remaining > 0.0: return false
	var candidates: Array[AttackPatternData] = []
	for pattern: AttackPatternData in patterns:
		if distance >= pattern.minimum_distance and distance <= pattern.maximum_distance: candidates.append(pattern)
	if candidates.is_empty(): return false
	start_attack(_pick_weighted(candidates))
	return true


func force_attack(id: StringName) -> bool:
	if busy: return false
	for pattern: AttackPatternData in patterns:
		if pattern.id == id:
			cooldown_remaining = 0.0; start_attack(pattern); return true
	return false


func start_attack(pattern: AttackPatternData) -> void:
	busy = true; current_pattern = pattern
	var direction := monster.global_position.direction_to(monster.player.global_position)
	telegraph.show_attack(pattern, direction)
	await get_tree().create_timer(pattern.telegraph_time).timeout
	if not is_instance_valid(monster) or monster.stagger_time > 0.0:
		busy = false; telegraph.hide_attack(); return
	telegraph.hide_attack()
	_execute(pattern)
	cooldown_remaining = pattern.cooldown
	busy = false


func _execute(pattern: AttackPatternData) -> void:
	var direction := monster.global_position.direction_to(monster.player.global_position)
	match pattern.mode:
		AttackPatternData.Mode.MELEE_LUNGE:
			monster.global_position += direction * 12.0
			var tween := monster.create_tween(); tween.tween_property(monster, "scale", Vector2(1.15, 0.84), 0.06); tween.tween_property(monster, "scale", Vector2.ONE, 0.1)
			if monster.global_position.distance_to(monster.player.global_position) <= pattern.maximum_distance:
				(monster.player.get_node("Hurtbox") as Hurtbox).receive_attack(pattern.attack, direction, monster)
		AttackPatternData.Mode.STRAIGHT_PROJECTILE, AttackPatternData.Mode.HOMING_PROJECTILE:
			var projectile: CombatProjectile = PROJECTILE_SCENE.instantiate()
			get_tree().current_scene.add_child(projectile); projectile.global_position = monster.global_position + direction * 10.0
			projectile.configure(pattern, monster, monster.player)
		AttackPatternData.Mode.SONIC_WAVE:
			var wave: SonicWave = SONIC_SCENE.instantiate()
			get_tree().current_scene.add_child(wave); wave.global_position = monster.global_position
			wave.configure(pattern, monster, monster.player)


func _pick_weighted(candidates: Array[AttackPatternData]) -> AttackPatternData:
	var total := 0.0
	for pattern: AttackPatternData in candidates: total += pattern.weight
	var roll := randf() * total
	for pattern: AttackPatternData in candidates:
		roll -= pattern.weight
		if roll <= 0.0: return pattern
	return candidates.back()
