class_name QuestSystem
extends Node

signal quest_updated(quest_id: StringName)
signal quest_completed(quest_id: StringName)

var quests: Dictionary = {}
var tracker: Label
const QUEST_PATHS := ["res://resources/quests/gather_wood.tres", "res://resources/quests/defeat_slimes.tres", "res://resources/quests/craft_workbench.tres"]


func _ready() -> void:
	add_to_group("quest_system")
	for path: String in QUEST_PATHS:
		var quest: QuestData = load(path); quests[quest.id] = quest
	GameState.inventory.item_added.connect(_on_item_added)
	GameState.monster_defeated.connect(_on_monster_defeated)
	GameState.item_crafted.connect(_on_item_crafted)
	_build_tracker()
	_refresh()


func start_quest(id: StringName) -> bool:
	var key := String(id)
	if GameState.quest_state.has(key): return false
	GameState.quest_state[key] = {"status": "active", "progress": 0}
	var quest: QuestData = quests[id]
	if quest.objective == QuestData.Objective.COLLECT_ITEM:
		GameState.quest_state[key]["progress"] = mini(GameState.inventory.count_item(quest.target_id), quest.required_amount)
	GameState.notify("Quest accepted: %s" % quest.title)
	_check_complete(id)
	_refresh()
	return true


func _progress(objective: QuestData.Objective, target: StringName, amount: int) -> void:
	for id: StringName in quests:
		var quest: QuestData = quests[id]
		var state: Dictionary = GameState.quest_state.get(String(id), {})
		if state.get("status", "") != "active" or quest.objective != objective or quest.target_id != target: continue
		state["progress"] = mini(int(state.get("progress", 0)) + amount, quest.required_amount)
		GameState.quest_state[String(id)] = state
		quest_updated.emit(id)
		_check_complete(id)
	_refresh()


func _check_complete(id: StringName) -> void:
	var quest: QuestData = quests[id]
	var state: Dictionary = GameState.quest_state.get(String(id), {})
	if state.get("status", "") == "active" and int(state.get("progress", 0)) >= quest.required_amount:
		state["status"] = "complete"
		GameState.quest_state[String(id)] = state
		GameState.add_gold(quest.gold_reward)
		GameState.notify("Quest complete: %s (+%d Gold)" % [quest.title, quest.gold_reward])
		quest_completed.emit(id)


func _on_item_added(id: StringName, amount: int) -> void: _progress(QuestData.Objective.COLLECT_ITEM, id, amount)
func _on_monster_defeated(id: StringName) -> void: _progress(QuestData.Objective.DEFEAT_MONSTER, id, 1)
func _on_item_crafted(id: StringName, amount: int) -> void: _progress(QuestData.Objective.CRAFT_ITEM, id, amount)


func _build_tracker() -> void:
	var layer := CanvasLayer.new(); layer.layer = 32; add_child(layer)
	tracker = Label.new(); tracker.position = Vector2(435, 8); tracker.custom_minimum_size = Vector2(195, 52); tracker.add_theme_font_size_override("font_size", 9); tracker.add_theme_color_override("font_color", Color("#fff0b0")); layer.add_child(tracker)


func _refresh() -> void:
	if tracker == null: return
	var lines: Array[String] = ["QUESTS"]
	for id: StringName in quests:
		var state: Dictionary = GameState.quest_state.get(String(id), {})
		if state.get("status", "") == "active":
			var quest: QuestData = quests[id]; lines.append("%s  %d/%d" % [quest.title, int(state.get("progress", 0)), quest.required_amount])
	tracker.text = "\n".join(lines)
