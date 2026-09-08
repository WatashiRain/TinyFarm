class_name StorageContainer
extends Node2D

@export var storage_id: StringName = &"chest_0"
var inventory := InventoryData.new()
var panel: PanelContainer
var chest_grid: GridContainer
var player_grid: GridContainer


func _ready() -> void:
	add_to_group("storage_containers")
	inventory.initialize(16)
	var saved: Dictionary = GameState.world_state.get("chests", {})
	if saved.has(String(storage_id)):
		inventory.apply_state(saved[String(storage_id)])
	inventory.changed.connect(_save)
	GameState.inventory.changed.connect(_refresh)
	_build_ui()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var player := get_tree().get_first_node_in_group("player") as PlayerController
		if player != null and player.global_position.distance_to(global_position) < 30.0:
			panel.visible = not panel.visible
			_refresh()


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 45
	add_child(layer)
	panel = PanelContainer.new()
	panel.position = Vector2(160, 55)
	panel.custom_minimum_size = Vector2(320, 235)
	panel.visible = false
	layer.add_child(panel)
	var row := HBoxContainer.new()
	panel.add_child(row)
	var left := VBoxContainer.new()
	row.add_child(left)
	var title := Label.new(); title.text = "PLAYER → CHEST"; title.add_theme_font_size_override("font_size", 10); left.add_child(title)
	player_grid = GridContainer.new(); player_grid.columns = 2; left.add_child(player_grid)
	for index: int in range(8):
		var button := Button.new(); button.custom_minimum_size = Vector2(72, 20); button.add_theme_font_size_override("font_size", 8); button.pressed.connect(_store.bind(index)); player_grid.add_child(button)
	var right := VBoxContainer.new(); row.add_child(right)
	var chest_title := Label.new(); chest_title.text = "CHEST → PLAYER"; chest_title.add_theme_font_size_override("font_size", 10); right.add_child(chest_title)
	chest_grid = GridContainer.new(); chest_grid.columns = 2; right.add_child(chest_grid)
	for index: int in range(16):
		var button := Button.new(); button.custom_minimum_size = Vector2(72, 20); button.add_theme_font_size_override("font_size", 8); button.pressed.connect(_take.bind(index)); chest_grid.add_child(button)
	_refresh()


func _store(index: int) -> void:
	_transfer(GameState.inventory, inventory, index)


func _take(index: int) -> void:
	_transfer(inventory, GameState.inventory, index)


func _transfer(source: InventoryData, destination: InventoryData, index: int) -> void:
	var slot: Dictionary = source.slots[index]
	if slot["item_id"] == &"": return
	var item: ItemData = GameState.get_item(slot["item_id"])
	if destination.add_item(item, int(slot["quantity"])) == 0:
		source.remove_item(item.id, int(slot["quantity"]))
	_refresh()


func _save() -> void:
	var chests: Dictionary = GameState.world_state.get("chests", {}).duplicate(true)
	chests[String(storage_id)] = inventory.to_state()
	GameState.world_state["chests"] = chests
	_refresh()


func reload_state() -> void:
	var saved: Dictionary = GameState.world_state.get("chests", {})
	if saved.has(String(storage_id)):
		inventory.apply_state(saved[String(storage_id)])
	else:
		inventory.initialize(16)
	_refresh()


func _refresh() -> void:
	if chest_grid == null: return
	for index: int in range(16): _button(chest_grid.get_child(index), inventory.slots[index])
	for index: int in range(8): _button(player_grid.get_child(index), GameState.inventory.slots[index])


func _button(button: Button, slot: Dictionary) -> void:
	button.text = "—" if slot["item_id"] == &"" else "%s ×%d" % [GameState.get_item(slot["item_id"]).display_name, slot["quantity"]]


func _draw() -> void:
	draw_rect(Rect2(-10, -8, 20, 16), Color("#6e402a"), true)
	draw_rect(Rect2(-10, -8, 20, 6), Color("#a56b38"), true)
	draw_rect(Rect2(-2, -2, 4, 5), Color("#e0b650"), true)
