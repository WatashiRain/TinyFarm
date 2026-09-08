extends Node

signal player_registered(stats: PlayerStats)
signal region_changed(region_id: StringName)
signal gold_changed(current: int)
signal notification_requested(message: String)
signal hotbar_changed(selected: int)

var current_region: StringName = &"farm"
var player_position := Vector2(352, 270)
var gold: int = 100
var unlocked_skills: Dictionary = {"dash": true, "power_slash": false, "healing_pulse": false}
var quest_state: Dictionary = {}
var world_state: Dictionary = {}
var player_stats: PlayerStats
var inventory: InventoryData
var selected_hotbar: int = 0
var _stored_stats: Dictionary = {}
var _items: Dictionary = {}

const ITEM_PATHS := [
	"res://resources/items/wood.tres", "res://resources/items/stone.tres", "res://resources/items/fiber.tres",
	"res://resources/items/turnip_seed.tres", "res://resources/items/turnip.tres", "res://resources/items/slime_gel.tres",
	"res://resources/items/basic_axe.tres", "res://resources/items/basic_pickaxe.tres", "res://resources/items/basic_hoe.tres",
	"res://resources/items/watering_can.tres", "res://resources/items/basic_sword.tres",
	"res://resources/items/carrot_seed.tres", "res://resources/items/carrot.tres",
	"res://resources/items/strawberry_seed.tres", "res://resources/items/strawberry.tres",
	"res://resources/items/wood_plank.tres", "res://resources/items/stone_block.tres",
	"res://resources/items/basic_chest.tres", "res://resources/items/workbench.tres",
	"res://resources/items/fence.tres", "res://resources/items/wood_floor.tres",
	"res://resources/items/bat_wing.tres", "res://resources/items/spirit_dust.tres",
]


func _ready() -> void:
	for path: String in ITEM_PATHS:
		var item: ItemData = load(path)
		_items[item.id] = item
	inventory = InventoryData.new()
	inventory.initialize(24)
	_seed_starting_tools()


func get_item(item_id: StringName) -> ItemData:
	return _items.get(item_id)


func select_hotbar(index: int) -> void:
	selected_hotbar = clampi(index, 0, 7)
	hotbar_changed.emit(selected_hotbar)


func selected_item_id() -> StringName:
	if inventory == null or selected_hotbar >= inventory.slots.size():
		return &""
	return inventory.slots[selected_hotbar]["item_id"]


func _seed_starting_tools() -> void:
	for item_id: StringName in [&"basic_axe", &"basic_pickaxe", &"basic_hoe", &"watering_can", &"basic_sword", &"turnip_seed"]:
		inventory.add_item(get_item(item_id), 1 if item_id != &"turnip_seed" else 5)


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
	return {"region": String(current_region), "player_position": [player_position.x, player_position.y], "gold": gold, "skills": unlocked_skills.duplicate(true), "quests": quest_state.duplicate(true), "world": world_state.duplicate(true), "stats": _stored_stats.duplicate(true), "inventory": inventory.to_state(), "selected_hotbar": selected_hotbar}


func apply_state(data: Dictionary) -> void:
	current_region = StringName(data.get("region", "farm"))
	var saved_position: Array = data.get("player_position", [352.0, 270.0])
	player_position = Vector2(float(saved_position[0]), float(saved_position[1]))
	gold = int(data.get("gold", 100))
	unlocked_skills = data.get("skills", unlocked_skills).duplicate(true)
	quest_state = data.get("quests", {}).duplicate(true)
	world_state = data.get("world", {}).duplicate(true)
	_stored_stats = data.get("stats", {}).duplicate(true)
	inventory.apply_state(data.get("inventory", []))
	select_hotbar(int(data.get("selected_hotbar", 0)))
	if player_stats != null:
		player_stats.apply_state(_stored_stats)
	region_changed.emit(current_region)
	gold_changed.emit(gold)
