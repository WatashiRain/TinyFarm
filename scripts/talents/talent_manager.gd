extends Node

signal points_changed(available: int, earned: int, spent: int)
signal rank_changed(talent_id: StringName, rank: int)
signal talents_rebuilt

const REGEN_INTERVAL := 2.0
const TALENT_PATHS: Array[String] = [
	"res://resources/talents/toughness_i.tres",
	"res://resources/talents/toughness_ii.tres",
	"res://resources/talents/iron_skin_i.tres",
	"res://resources/talents/iron_skin_ii.tres",
	"res://resources/talents/endurance.tres",
	"res://resources/talents/second_wind.tres",
	"res://resources/talents/swift_step.tres",
	"res://resources/talents/dash_training.tres",
	"res://resources/talents/efficient_dash.tres",
	"res://resources/talents/quick_recovery.tres",
	"res://resources/talents/mana_pool.tres",
	"res://resources/talents/efficient_casting.tres",
	"res://resources/talents/arcane_efficiency.tres",
	"res://resources/talents/arcane_power.tres",
	"res://resources/talents/mana_flow.tres",
]

var talents: Dictionary = {}
var talent_list: Array[TalentData] = []
var ranks: Dictionary = {}
var earned_points: int = 0
var spent_points: int = 0
var player_stats: PlayerStats
var mana_regen_amount: int = 0
var second_wind_amount: int = 0

var _regen_timer: Timer
var _second_wind_timer: Timer
var _handling_second_wind := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	for path: String in TALENT_PATHS:
		var talent := load(path) as TalentData
		if talent != null:
			talents[String(talent.id)] = talent
			talent_list.append(talent)
	_regen_timer = Timer.new()
	_regen_timer.wait_time = REGEN_INTERVAL
	_regen_timer.timeout.connect(_on_regen_tick)
	add_child(_regen_timer)
	_second_wind_timer = Timer.new()
	_second_wind_timer.one_shot = true
	add_child(_second_wind_timer)


func bind_player(stats: PlayerStats) -> void:
	if player_stats == stats:
		rebuild_player_modifiers()
		return
	if player_stats != null and player_stats.health_changed.is_connected(_on_health_changed):
		player_stats.health_changed.disconnect(_on_health_changed)
	player_stats = stats
	if player_stats != null and not player_stats.health_changed.is_connected(_on_health_changed):
		player_stats.health_changed.connect(_on_health_changed)
	rebuild_player_modifiers()


func available_points() -> int:
	return maxi(0, earned_points - spent_points)


func get_rank(talent_id: StringName) -> int:
	return int(ranks.get(String(talent_id), 0))


func get_talent(talent_id: StringName) -> TalentData:
	return talents.get(String(talent_id)) as TalentData


func grant_for_levels(levels_gained: int) -> void:
	if levels_gained <= 0:
		return
	grant_points(levels_gained, false)
	GameState.notify("LEVEL UP\n+%d TALENT POINT%s" % [levels_gained, "" if levels_gained == 1 else "S"])


func grant_points(amount: int, notify_user := true) -> void:
	if amount <= 0:
		return
	earned_points += amount
	points_changed.emit(available_points(), earned_points, spent_points)
	if notify_user:
		GameState.notify("+%d Talent Point%s" % [amount, "" if amount == 1 else "s"])


func purchase_talent(talent_id: StringName) -> bool:
	var talent := get_talent(talent_id)
	var rejection := purchase_rejection_reason(talent_id)
	if talent == null or not rejection.is_empty():
		GameState.notify(rejection if not rejection.is_empty() else "Unknown talent")
		return false
	var new_rank := get_rank(talent_id) + 1
	ranks[String(talent_id)] = new_rank
	spent_points += talent.cost_per_rank
	rebuild_player_modifiers()
	rank_changed.emit(talent_id, new_rank)
	points_changed.emit(available_points(), earned_points, spent_points)
	GameState.notify("Learned %s %d/%d" % [talent.display_name, new_rank, talent.max_rank])
	return true


func purchase_rejection_reason(talent_id: StringName) -> String:
	var talent := get_talent(talent_id)
	if talent == null:
		return "Unknown talent"
	if get_rank(talent_id) >= talent.max_rank:
		return "Talent is already at maximum rank"
	if player_stats != null and player_stats.level < talent.required_level:
		return "Requires level %d" % talent.required_level
	for prerequisite: StringName in talent.prerequisite_ids:
		if get_rank(prerequisite) <= 0:
			var required := get_talent(prerequisite)
			return "Requires %s" % (required.display_name if required != null else String(prerequisite))
	if available_points() < talent.cost_per_rank:
		return "Not enough Talent Points"
	return ""


func is_unlocked(talent_id: StringName) -> bool:
	var talent := get_talent(talent_id)
	if talent == null:
		return false
	if player_stats != null and player_stats.level < talent.required_level:
		return false
	for prerequisite: StringName in talent.prerequisite_ids:
		if get_rank(prerequisite) <= 0:
			return false
	return true


func reset_talents(notify_user := true) -> void:
	ranks.clear()
	spent_points = 0
	_second_wind_timer.stop()
	rebuild_player_modifiers()
	points_changed.emit(available_points(), earned_points, spent_points)
	if notify_user:
		GameState.notify("Talents reset — %d points refunded" % available_points())


func reset_progression(notify_user := false) -> void:
	ranks.clear()
	earned_points = 0
	spent_points = 0
	_second_wind_timer.stop()
	rebuild_player_modifiers()
	points_changed.emit(0, 0, 0)
	if notify_user:
		GameState.notify("Talent progression reset")


func rebuild_player_modifiers() -> void:
	var modifiers := {
		"max_health": 0.0,
		"defense": 0.0,
		"move_speed_percent": 0.0,
		"max_mana": 0.0,
		"max_energy": 0.0,
		"healing_effectiveness_percent": 0.0,
		"global_mana_cost_percent": 0.0,
		"global_cooldown_percent": 0.0,
		"skill_mana_cost_percent": {},
		"skill_cooldown_percent": {},
		"skill_power_percent": {},
	}
	mana_regen_amount = 0
	second_wind_amount = 0
	for talent: TalentData in talent_list:
		var rank := get_rank(talent.id)
		if rank <= 0:
			continue
		var value := talent.value_for_rank(rank)
		match talent.effect_type:
			TalentData.EffectType.MAX_HEALTH:
				modifiers["max_health"] += value
			TalentData.EffectType.DEFENSE:
				modifiers["defense"] += value
			TalentData.EffectType.MOVE_SPEED_PERCENT:
				modifiers["move_speed_percent"] += value
			TalentData.EffectType.MAX_MANA:
				modifiers["max_mana"] += value
			TalentData.EffectType.MAX_ENERGY:
				modifiers["max_energy"] += value
			TalentData.EffectType.HEALING_EFFECTIVENESS:
				modifiers["healing_effectiveness_percent"] += value
			TalentData.EffectType.MANA_REGEN:
				mana_regen_amount += roundi(value)
			TalentData.EffectType.SKILL_MANA_COST_PERCENT:
				_add_skill_modifier(modifiers, "skill_mana_cost_percent", "global_mana_cost_percent", talent.target_skill, value)
			TalentData.EffectType.SKILL_COOLDOWN_PERCENT:
				_add_skill_modifier(modifiers, "skill_cooldown_percent", "global_cooldown_percent", talent.target_skill, value)
			TalentData.EffectType.SKILL_POWER_PERCENT:
				var powers: Dictionary = modifiers["skill_power_percent"]
				powers[String(talent.target_skill)] = float(powers.get(String(talent.target_skill), 0.0)) + value
			TalentData.EffectType.SECOND_WIND:
				second_wind_amount += roundi(value)
	if player_stats != null:
		player_stats.apply_talent_modifiers(modifiers)
	_update_regen_timer()
	talents_rebuilt.emit()


func _add_skill_modifier(modifiers: Dictionary, skill_key: String, global_key: String, target: StringName, value: float) -> void:
	if target.is_empty():
		modifiers[global_key] += value
	else:
		var skill_values: Dictionary = modifiers[skill_key]
		skill_values[String(target)] = float(skill_values.get(String(target), 0.0)) + value


func _update_regen_timer() -> void:
	if _regen_timer == null:
		return
	if mana_regen_amount > 0:
		if _regen_timer.is_stopped():
			_regen_timer.start()
	else:
		_regen_timer.stop()


func _on_regen_tick() -> void:
	if player_stats != null and mana_regen_amount > 0 and player_stats.mana < player_stats.max_mana:
		player_stats.restore_mana(mana_regen_amount)


func _on_health_changed(current: int, maximum: int) -> void:
	if _handling_second_wind or second_wind_amount <= 0 or current <= 0:
		return
	if current > floori(maximum * 0.30) or not _second_wind_timer.is_stopped():
		return
	var talent := get_talent(&"second_wind")
	_second_wind_timer.wait_time = talent.passive_cooldown if talent != null else 30.0
	_second_wind_timer.start()
	_handling_second_wind = true
	player_stats.heal(second_wind_amount)
	_handling_second_wind = false
	GameState.notify("Second Wind restored %d HP" % second_wind_amount)


func to_state() -> Dictionary:
	return {
		"earned_points": earned_points,
		"spent_points": spent_points,
		"available_points": available_points(),
		"ranks": ranks.duplicate(true),
		"unlocked_nodes": _unlocked_node_ids(),
	}


func apply_state(data: Dictionary, legacy_level := 1) -> void:
	ranks.clear()
	if data.is_empty():
		earned_points = maxi(0, legacy_level - 1)
		spent_points = 0
	else:
		var saved_ranks: Dictionary = data.get("ranks", {})
		for id: Variant in saved_ranks.keys():
			var talent := get_talent(StringName(String(id)))
			if talent != null:
				ranks[String(id)] = clampi(int(saved_ranks[id]), 0, talent.max_rank)
		spent_points = _calculate_spent_points()
		var saved_earned := int(data.get("earned_points", spent_points + int(data.get("available_points", 0))))
		earned_points = maxi(spent_points, saved_earned)
	rebuild_player_modifiers()
	points_changed.emit(available_points(), earned_points, spent_points)


func _calculate_spent_points() -> int:
	var total := 0
	for id: Variant in ranks.keys():
		var talent := get_talent(StringName(String(id)))
		if talent != null:
			total += int(ranks[id]) * talent.cost_per_rank
	return total


func _unlocked_node_ids() -> Array[String]:
	var result: Array[String] = []
	for talent: TalentData in talent_list:
		if is_unlocked(talent.id):
			result.append(String(talent.id))
	return result
