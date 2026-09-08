class_name QuestData
extends Resource

enum Objective { COLLECT_ITEM, DEFEAT_MONSTER, CRAFT_ITEM }

@export var id: StringName
@export var title: String
@export_multiline var description: String
@export var objective: Objective
@export var target_id: StringName
@export var required_amount: int = 1
@export var gold_reward: int = 25
