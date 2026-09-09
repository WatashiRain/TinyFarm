class_name TalentData
extends Resource

enum Branch { VITALITY, AGILITY, MANA, MANA_REGEN }
enum EffectType {
	MAX_HEALTH,
	DEFENSE,
	MOVE_SPEED_PERCENT,
	MAX_MANA,
	MANA_REGEN,
	SKILL_MANA_COST_PERCENT,
	SKILL_COOLDOWN_PERCENT,
	MAX_ENERGY,
	HEALING_EFFECTIVENESS,
	SKILL_POWER_PERCENT,
	SECOND_WIND,
}

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var branch: Branch
@export_range(1, 10, 1) var max_rank: int = 1
@export_range(1, 10, 1) var cost_per_rank: int = 1
@export var prerequisite_ids: Array[StringName] = []
@export_range(1, 99, 1) var required_level: int = 1
@export var effect_type: EffectType
@export var effect_value: float
@export var rank_effect_values: PackedFloat32Array = []
@export var target_skill: StringName
@export var passive_cooldown: float = 30.0
@export var icon_placeholder_color: Color = Color.WHITE
@export var ui_position: Vector2


func value_for_rank(rank: int) -> float:
	if rank <= 0:
		return 0.0
	if rank_effect_values.size() >= rank:
		return rank_effect_values[rank - 1]
	return effect_value * rank
