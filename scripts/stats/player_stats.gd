class_name PlayerStats
extends Node

signal stats_changed
signal health_changed(current: int, maximum: int)
signal energy_changed(current: int, maximum: int)
signal mana_changed(current: int, maximum: int)
signal experience_changed(current: int, required: int)
signal level_changed(level: int)
signal died

@export var base_max_health: int = 100
@export var base_max_energy: int = 100
@export var base_max_mana: int = 50
@export var level: int = 1
@export var experience: int = 0
@export var base_attack: int = 10
@export var base_defense: int = 2

var max_health: int = 100
var max_energy: int = 100
var max_mana: int = 50
var attack: int = 10
var defense: int = 2
var health: int
var energy: int
var mana: int
var movement_speed_multiplier: float = 1.0
var healing_effectiveness_multiplier: float = 1.0

var _talent_modifiers: Dictionary = {}
var _global_mana_cost_percent := 0.0
var _global_cooldown_percent := 0.0
var _skill_mana_cost_percent: Dictionary = {}
var _skill_cooldown_percent: Dictionary = {}
var _skill_power_percent: Dictionary = {}


func _ready() -> void:
	_recalculate_final_stats(false)
	health = max_health
	energy = max_energy
	mana = max_mana
	GameState.register_player(self)
	_emit_all()


func take_damage(amount: int) -> int:
	var applied := maxi(1, amount - defense)
	health = maxi(0, health - applied)
	health_changed.emit(health, max_health)
	stats_changed.emit()
	if health == 0:
		died.emit()
	return applied


func heal(amount: int) -> void:
	var effective_amount := roundi(maxi(0, amount) * healing_effectiveness_multiplier)
	health = mini(max_health, health + effective_amount)
	health_changed.emit(health, max_health)
	stats_changed.emit()


func consume_energy(amount: int) -> bool:
	if energy < amount:
		return false
	energy -= amount
	energy_changed.emit(energy, max_energy)
	stats_changed.emit()
	return true


func restore_energy(amount: int) -> void:
	energy = mini(max_energy, energy + maxi(0, amount))
	energy_changed.emit(energy, max_energy)
	stats_changed.emit()


func consume_mana(amount: int) -> bool:
	if mana < amount:
		return false
	mana -= amount
	mana_changed.emit(mana, max_mana)
	stats_changed.emit()
	return true


func restore_mana(amount: int) -> void:
	mana = mini(max_mana, mana + maxi(0, amount))
	mana_changed.emit(mana, max_mana)
	stats_changed.emit()


func add_experience(amount: int) -> void:
	experience += maxi(0, amount)
	var levels_gained := 0
	while experience >= experience_to_next_level():
		experience -= experience_to_next_level()
		level += 1
		levels_gained += 1
		level_changed.emit(level)
	if levels_gained > 0:
		TalentManager.grant_for_levels(levels_gained)
	experience_changed.emit(experience, experience_to_next_level())
	stats_changed.emit()


func experience_to_next_level() -> int:
	return 25 + (level - 1) * 20


func restore_all() -> void:
	health = max_health
	energy = max_energy
	mana = max_mana
	_emit_all()


func to_state() -> Dictionary:
	return {
		"health": health, "energy": energy, "mana": mana,
		"base_max_health": base_max_health, "base_max_energy": base_max_energy, "base_max_mana": base_max_mana,
		"base_attack": base_attack, "base_defense": base_defense,
		"max_health": max_health, "max_energy": max_energy, "max_mana": max_mana,
		"level": level, "experience": experience,
	}


func apply_state(data: Dictionary) -> void:
	if data.is_empty():
		return
	# Legacy saves stored already-earned level bonuses in max_*; preserve those as base values.
	base_max_health = int(data.get("base_max_health", data.get("max_health", 100)))
	base_max_energy = int(data.get("base_max_energy", data.get("max_energy", 100)))
	base_max_mana = int(data.get("base_max_mana", data.get("max_mana", 50)))
	base_attack = int(data.get("base_attack", data.get("attack", 10)))
	base_defense = int(data.get("base_defense", data.get("defense", 2)))
	level = int(data.get("level", 1))
	experience = int(data.get("experience", 0))
	_recalculate_final_stats(false)
	health = clampi(int(data.get("health", max_health)), 0, max_health)
	energy = clampi(int(data.get("energy", max_energy)), 0, max_energy)
	mana = clampi(int(data.get("mana", max_mana)), 0, max_mana)
	_emit_all()


func reset_base_stats() -> void:
	base_max_health = 100
	base_max_energy = 100
	base_max_mana = 50
	base_attack = 10
	base_defense = 2
	level = 1
	experience = 0
	_talent_modifiers.clear()
	_recalculate_final_stats(false)
	restore_all()


func apply_talent_modifiers(modifiers: Dictionary) -> void:
	_talent_modifiers = modifiers.duplicate(true)
	_recalculate_final_stats(true)


func adjusted_skill_mana_cost(base_cost: int, skill_id: StringName) -> int:
	var reduction := _global_mana_cost_percent + float(_skill_mana_cost_percent.get(String(skill_id), 0.0))
	return maxi(0, floori(base_cost * (1.0 - clampf(reduction, 0.0, 90.0) / 100.0)))


func adjusted_skill_cooldown(base_cooldown: float, skill_id: StringName) -> float:
	var reduction := _global_cooldown_percent + float(_skill_cooldown_percent.get(String(skill_id), 0.0))
	return maxf(0.05, base_cooldown * (1.0 - clampf(reduction, 0.0, 90.0) / 100.0))


func skill_power_multiplier(skill_id: StringName) -> float:
	return 1.0 + float(_skill_power_percent.get(String(skill_id), 0.0)) / 100.0


func _recalculate_final_stats(emit_changes: bool) -> void:
	max_health = base_max_health + roundi(float(_talent_modifiers.get("max_health", 0.0)))
	max_energy = base_max_energy + roundi(float(_talent_modifiers.get("max_energy", 0.0)))
	max_mana = base_max_mana + roundi(float(_talent_modifiers.get("max_mana", 0.0)))
	attack = base_attack
	defense = base_defense + roundi(float(_talent_modifiers.get("defense", 0.0)))
	movement_speed_multiplier = 1.0 + float(_talent_modifiers.get("move_speed_percent", 0.0)) / 100.0
	healing_effectiveness_multiplier = 1.0 + float(_talent_modifiers.get("healing_effectiveness_percent", 0.0)) / 100.0
	_global_mana_cost_percent = float(_talent_modifiers.get("global_mana_cost_percent", 0.0))
	_global_cooldown_percent = float(_talent_modifiers.get("global_cooldown_percent", 0.0))
	_skill_mana_cost_percent = Dictionary(_talent_modifiers.get("skill_mana_cost_percent", {})).duplicate(true)
	_skill_cooldown_percent = Dictionary(_talent_modifiers.get("skill_cooldown_percent", {})).duplicate(true)
	_skill_power_percent = Dictionary(_talent_modifiers.get("skill_power_percent", {})).duplicate(true)
	health = clampi(health, 0, max_health)
	energy = clampi(energy, 0, max_energy)
	mana = clampi(mana, 0, max_mana)
	if emit_changes:
		_emit_all()


func _emit_all() -> void:
	health_changed.emit(health, max_health)
	energy_changed.emit(energy, max_energy)
	mana_changed.emit(mana, max_mana)
	experience_changed.emit(experience, experience_to_next_level())
	level_changed.emit(level)
	stats_changed.emit()
