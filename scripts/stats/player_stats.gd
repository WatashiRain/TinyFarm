class_name PlayerStats
extends Node

signal stats_changed
signal health_changed(current: int, maximum: int)
signal energy_changed(current: int, maximum: int)
signal mana_changed(current: int, maximum: int)
signal experience_changed(current: int, required: int)
signal level_changed(level: int)
signal died

@export var max_health: int = 100
@export var max_energy: int = 100
@export var max_mana: int = 50
@export var level: int = 1
@export var experience: int = 0
@export var attack: int = 10
@export var defense: int = 2

var health: int
var energy: int
var mana: int


func _ready() -> void:
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
	health = mini(max_health, health + maxi(0, amount))
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
	while experience >= experience_to_next_level():
		experience -= experience_to_next_level()
		level += 1
		max_health += 5
		max_energy += 3
		health = max_health
		energy = max_energy
		level_changed.emit(level)
		GameState.notify("Level up! Level %d" % level)
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
	return {"health": health, "max_health": max_health, "energy": energy, "max_energy": max_energy, "mana": mana, "max_mana": max_mana, "level": level, "experience": experience, "attack": attack, "defense": defense}


func apply_state(data: Dictionary) -> void:
	if data.is_empty():
		return
	max_health = int(data.get("max_health", 100))
	max_energy = int(data.get("max_energy", 100))
	max_mana = int(data.get("max_mana", 50))
	health = int(data.get("health", max_health))
	energy = int(data.get("energy", max_energy))
	mana = int(data.get("mana", max_mana))
	level = int(data.get("level", 1))
	experience = int(data.get("experience", 0))
	attack = int(data.get("attack", 10))
	defense = int(data.get("defense", 2))
	_emit_all()


func _emit_all() -> void:
	health_changed.emit(health, max_health)
	energy_changed.emit(energy, max_energy)
	mana_changed.emit(mana, max_mana)
	experience_changed.emit(experience, experience_to_next_level())
	level_changed.emit(level)
	stats_changed.emit()
