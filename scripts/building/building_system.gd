class_name BuildingSystem
extends Node2D

const CHEST_SCENE := preload("res://scenes/building/storage_container.tscn")
const PLACEABLES: Array[StringName] = [&"workbench", &"basic_chest", &"fence", &"wood_floor"]
const POND_BOUNDS := Rect2(390, 190, 155, 140)

var build_mode := false
var selected_index := 0
var buildings: Array = []
var player: PlayerController


func _ready() -> void:
	add_to_group("building_system")
	player = get_tree().get_first_node_in_group("player")
	buildings = GameState.world_state.get("placed_buildings", []).duplicate(true)
	for data: Dictionary in buildings:
		if StringName(data.get("type", "")) == &"basic_chest":
			_spawn_chest(data)
	queue_redraw()


func _process(_delta: float) -> void:
	if build_mode:
		queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("build_mode"):
		build_mode = not build_mode
		if build_mode:
			_select_available()
		GameState.notify("Build: %s" % (GameState.get_item(selected_type()).display_name if build_mode else "off"))
		get_viewport().set_input_as_handled()
	elif build_mode and event.is_action_pressed("build_place"):
		place_selected()
		get_viewport().set_input_as_handled()


func selected_type() -> StringName:
	return PLACEABLES[selected_index]


func place_selected() -> bool:
	var item_id := selected_type()
	if not GameState.inventory.contains(item_id):
		GameState.notify("Craft %s first" % GameState.get_item(item_id).display_name)
		return false
	var cell := target_cell()
	if not is_valid_cell(cell):
		GameState.notify("Cannot build here")
		return false
	GameState.inventory.remove_item(item_id, 1)
	var data := {"type": String(item_id), "cell": [cell.x, cell.y]}
	buildings.append(data)
	GameState.world_state["placed_buildings"] = buildings.duplicate(true)
	if item_id == &"basic_chest":
		_spawn_chest(data)
	GameState.notify("Placed %s" % GameState.get_item(item_id).display_name)
	queue_redraw()
	_select_available()
	return true


func target_cell() -> Vector2i:
	var target := player.get_node("ToolController") as ToolController
	return Vector2i(floori(target.target_position().x / 16.0), floori(target.target_position().y / 16.0))


func is_valid_cell(cell: Vector2i) -> bool:
	var center := Vector2(cell * 16) + Vector2(8, 8)
	if POND_BOUNDS.has_point(center):
		return false
	if Vector2i(floori(player.global_position.x / 16.0), floori(player.global_position.y / 16.0)) == cell:
		return false
	for data: Dictionary in buildings:
		var saved: Array = data.get("cell", [])
		if saved.size() == 2 and Vector2i(int(saved[0]), int(saved[1])) == cell:
			return false
	return true


func _select_available() -> void:
	for offset: int in range(PLACEABLES.size()):
		var candidate := (selected_index + offset) % PLACEABLES.size()
		if GameState.inventory.contains(PLACEABLES[candidate]):
			selected_index = candidate
			return


func _spawn_chest(data: Dictionary) -> void:
	var saved: Array = data["cell"]
	var cell := Vector2i(int(saved[0]), int(saved[1]))
	var chest: StorageContainer = CHEST_SCENE.instantiate()
	chest.storage_id = StringName("chest_%d_%d" % [cell.x, cell.y])
	chest.position = Vector2(cell * 16) + Vector2(8, 8)
	add_child(chest)


func _draw() -> void:
	for data: Dictionary in buildings:
		var saved: Array = data["cell"]
		_draw_building(StringName(data["type"]), Vector2(int(saved[0]) * 16 + 8, int(saved[1]) * 16 + 8), Color.WHITE)
	if build_mode and player != null:
		var cell := target_cell()
		var tint := Color(0.55, 1.0, 0.55, 0.65) if is_valid_cell(cell) else Color(1.0, 0.35, 0.35, 0.65)
		_draw_building(selected_type(), Vector2(cell * 16) + Vector2(8, 8), tint)


func _draw_building(type: StringName, center: Vector2, tint: Color) -> void:
	if type == &"basic_chest":
		if tint.a < 1.0: draw_rect(Rect2(center - Vector2(10, 8), Vector2(20, 16)), Color("#8a5635") * tint, true)
	elif type == &"workbench":
		draw_rect(Rect2(center - Vector2(12, 7), Vector2(24, 8)), Color("#9d673c") * tint, true)
		draw_line(center + Vector2(-9, 1), center + Vector2(-9, 8), Color("#583d2c") * tint, 3.0)
		draw_line(center + Vector2(9, 1), center + Vector2(9, 8), Color("#583d2c") * tint, 3.0)
	elif type == &"fence":
		draw_line(center + Vector2(-8, -5), center + Vector2(-8, 7), Color("#b27a45") * tint, 3.0)
		draw_line(center + Vector2(8, -5), center + Vector2(8, 7), Color("#b27a45") * tint, 3.0)
		draw_line(center + Vector2(-9, 0), center + Vector2(9, 0), Color("#d09755") * tint, 3.0)
	else:
		draw_rect(Rect2(center - Vector2(8, 8), Vector2(16, 16)), Color("#95613d") * tint, true)
		draw_line(center + Vector2(-7, -2), center + Vector2(7, -2), Color("#c18a58") * tint, 1.0)
