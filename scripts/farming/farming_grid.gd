class_name FarmingGrid
extends Node2D

enum Soil { NORMAL, TILLED, WET }

@export var grid_size := Vector2i(6, 4)
@export var cell_size := 16
var cells: Dictionary = {}
var crops: Dictionary = {}

const CROP_PATHS := [
	"res://resources/crops/turnip.tres",
	"res://resources/crops/carrot.tres",
	"res://resources/crops/strawberry.tres",
]


func _ready() -> void:
	add_to_group("farming_grid")
	for path: String in CROP_PATHS:
		var crop: CropData = load(path)
		crops[crop.id] = crop
	_load_state()
	TimeManager.day_started.connect(_on_day_started)
	queue_redraw()


func use_item(item_id: StringName, global_target: Vector2) -> bool:
	var cell := world_to_cell(global_target)
	if not _inside(cell):
		return false
	var data := _cell(cell)
	if item_id == &"basic_hoe" and int(data["soil"]) == Soil.NORMAL:
		data["soil"] = Soil.TILLED
		GameState.notify("Soil tilled")
	elif item_id == &"watering_can" and int(data["soil"]) != Soil.NORMAL:
		data["soil"] = Soil.WET
		data["watered"] = true
		GameState.notify("Soil watered")
	elif item_id in [&"turnip_seed", &"carrot_seed", &"strawberry_seed"] and int(data["soil"]) != Soil.NORMAL and StringName(data["crop_id"]) == &"":
		if not GameState.inventory.remove_item(item_id, 1):
			return false
		data["crop_id"] = StringName(String(item_id).trim_suffix("_seed"))
		data["stage"] = 0
		data["growth_days"] = 0
		GameState.notify("Seed planted")
	else:
		return false
	cells[_key(cell)] = data
	_save_state()
	queue_redraw()
	return true


func harvest(global_target: Vector2) -> bool:
	var cell := world_to_cell(global_target)
	if not _inside(cell):
		return false
	var data := _cell(cell)
	var crop_id := StringName(data["crop_id"])
	if crop_id == &"":
		return false
	var crop: CropData = crops[crop_id]
	if int(data["stage"]) < crop.growth_stages - 1:
		GameState.notify("Crop is still growing")
		return true
	var remaining := GameState.inventory.add_item(GameState.get_item(crop.harvest_item_id), 1)
	if remaining > 0:
		GameState.notify("Inventory full")
		return true
	if crop.regrows:
		data["stage"] = crop.growth_stages - 2
	else:
		data["crop_id"] = &""
		data["stage"] = 0
	data["watered"] = false
	data["soil"] = Soil.TILLED
	cells[_key(cell)] = data
	_save_state()
	queue_redraw()
	GameState.notify("Harvested %s" % crop.display_name)
	return true


func world_to_cell(global_target: Vector2) -> Vector2i:
	var local := to_local(global_target)
	return Vector2i(floori(local.x / cell_size), floori(local.y / cell_size))


func cell_center(cell: Vector2i) -> Vector2:
	return to_global(Vector2(cell * cell_size) + Vector2.ONE * cell_size * 0.5)


func _on_day_started(_day: int) -> void:
	for key: String in cells:
		var data: Dictionary = cells[key]
		if StringName(data["crop_id"]) != &"" and bool(data["watered"]):
			var crop: CropData = crops[StringName(data["crop_id"])]
			data["growth_days"] = int(data["growth_days"]) + 1
			if int(data["growth_days"]) >= crop.days_per_stage:
				data["growth_days"] = 0
				data["stage"] = mini(int(data["stage"]) + 1, crop.growth_stages - 1)
		data["watered"] = false
		if int(data["soil"]) == Soil.WET:
			data["soil"] = Soil.TILLED
		cells[key] = data
	_save_state()
	queue_redraw()


func _cell(cell: Vector2i) -> Dictionary:
	return cells.get(_key(cell), {"soil": Soil.NORMAL, "watered": false, "crop_id": &"", "stage": 0, "growth_days": 0}).duplicate(true)


func _key(cell: Vector2i) -> String:
	return "%d,%d" % [cell.x, cell.y]


func _inside(cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < grid_size.x and cell.y < grid_size.y


func _save_state() -> void:
	GameState.world_state["farm_cells"] = cells.duplicate(true)


func _load_state() -> void:
	cells = GameState.world_state.get("farm_cells", {}).duplicate(true)


func _draw() -> void:
	for y: int in range(grid_size.y):
		for x: int in range(grid_size.x):
			var cell := Vector2i(x, y)
			var rect := Rect2(Vector2(cell * cell_size), Vector2.ONE * cell_size)
			var data := _cell(cell)
			var soil := int(data["soil"])
			if soil != Soil.NORMAL:
				draw_rect(rect.grow(-1), Color("#7d4f3c") if soil == Soil.TILLED else Color("#526b68"), true)
			draw_rect(rect, Color(0.94, 0.82, 0.55, 0.22), false, 1.0)
			var crop_id := StringName(data["crop_id"])
			if crop_id != &"":
				_draw_crop(rect.get_center(), crops[crop_id], int(data["stage"]))


func _draw_crop(center: Vector2, crop: CropData, stage: int) -> void:
	var color := crop.stage_colors[mini(stage, crop.stage_colors.size() - 1)]
	if stage == 0:
		draw_rect(Rect2(center - Vector2(1, 1), Vector2(3, 3)), color)
	else:
		var height := 3 + stage * 2
		draw_line(center + Vector2(0, 5), center + Vector2(0, 5 - height), Color("#3d6f3d"), 2.0)
		draw_circle(center + Vector2(-2, 4 - height), 2 + stage * 0.5, color)
		draw_circle(center + Vector2(2, 4 - height), 2 + stage * 0.5, color.lightened(0.12))
