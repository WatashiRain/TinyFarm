extends Node

signal game_saved(path: String)
signal game_loaded(path: String)
signal save_failed(message: String)

const SAVE_VERSION := 1
const SAVE_PATH := "user://tinyfarm_save.json"
var active_save_path := SAVE_PATH


func save_game() -> bool:
	var payload := {"save_version": SAVE_VERSION, "game": GameState.to_state(), "time": TimeManager.to_state()}
	var file := FileAccess.open(active_save_path, FileAccess.WRITE)
	if file == null:
		save_failed.emit("Could not open save file")
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	GameState.notify("Game saved")
	game_saved.emit(active_save_path)
	return true


func load_game() -> bool:
	if not FileAccess.file_exists(active_save_path):
		GameState.notify("No save found")
		return false
	var file := FileAccess.open(active_save_path, FileAccess.READ)
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY or int(parsed.get("save_version", 0)) != SAVE_VERSION:
		save_failed.emit("Unsupported save data")
		return false
	GameState.apply_state(parsed.get("game", {}))
	TimeManager.apply_state(parsed.get("time", {}))
	_refresh_live_world()
	GameState.notify("Game loaded")
	game_loaded.emit(active_save_path)
	return true


func new_game() -> void:
	GameState.reset_new_game()
	TimeManager.apply_state({"day": 1, "hour": 6, "minute": 0})
	_refresh_live_world()
	GameState.notify("New game started")


func _refresh_live_world() -> void:
	var player := get_tree().get_first_node_in_group("player") as PlayerController
	if player != null: player.global_position = GameState.player_position
	for farm: FarmingGrid in get_tree().get_nodes_in_group("farming_grid"): farm.reload_state()
	for builder: BuildingSystem in get_tree().get_nodes_in_group("building_system"): builder.reload_state()
	for resource: ResourceNode in get_tree().get_nodes_in_group("resource_nodes"): resource.reload_state()
	for chest: StorageContainer in get_tree().get_nodes_in_group("storage_containers"): chest.reload_state()
