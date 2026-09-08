extends Node

signal player_registered(stats: PlayerStats)
signal region_changed(region_id: StringName)
signal gold_changed(current: int)
signal notification_requested(message: String)

var current_region: StringName = &"farm"
var player_position := Vector2(352, 270)
var gold: int = 100
var unlocked_skills: Dictionary = {"dash": true, "power_slash": false, "healing_pulse": false}
var quest_state: Dictionary = {}
var world_state: Dictionary = {}
var player_stats: PlayerStats
var _stored_stats: Dictionary = {}


func register_player(stats: PlayerStats) -> void:
	player_stats = stats
	if not _stored_stats.is_empty():
		player_stats.apply_state(_stored_stats)
	if not player_stats.stats_changed.is_connected(_remember_stats):
		player_stats.stats_changed.connect(_remember_stats)
	_remember_stats()
	player_registered.emit(player_stats)


func set_region(region_id: StringName) -> void:
	if current_region == region_id:
		return
	current_region = region_id
	region_changed.emit(current_region)


func add_gold(amount: int) -> void:
	gold = maxi(0, gold + amount)
	gold_changed.emit(gold)


func spend_gold(amount: int) -> bool:
	if amount < 0 or gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true


func notify(message: String) -> void:
	notification_requested.emit(message)


func _remember_stats() -> void:
	if player_stats != null:
		_stored_stats = player_stats.to_state()


func to_state() -> Dictionary:
	_remember_stats()
	return {"region": String(current_region), "player_position": [player_position.x, player_position.y], "gold": gold, "skills": unlocked_skills.duplicate(true), "quests": quest_state.duplicate(true), "world": world_state.duplicate(true), "stats": _stored_stats.duplicate(true)}


func apply_state(data: Dictionary) -> void:
	current_region = StringName(data.get("region", "farm"))
	var saved_position: Array = data.get("player_position", [352.0, 270.0])
	player_position = Vector2(float(saved_position[0]), float(saved_position[1]))
	gold = int(data.get("gold", 100))
	unlocked_skills = data.get("skills", unlocked_skills).duplicate(true)
	quest_state = data.get("quests", {}).duplicate(true)
	world_state = data.get("world", {}).duplicate(true)
	_stored_stats = data.get("stats", {}).duplicate(true)
	if player_stats != null:
		player_stats.apply_state(_stored_stats)
	region_changed.emit(current_region)
	gold_changed.emit(gold)
