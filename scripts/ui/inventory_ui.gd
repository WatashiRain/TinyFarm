class_name InventoryUI
extends CanvasLayer

@onready var inventory_panel: PanelContainer = $InventoryPanel
@onready var inventory_grid: GridContainer = $InventoryPanel/Layout/Grid
@onready var hotbar: HBoxContainer = $Hotbar/Layout
@onready var selected_label: Label = $SelectedItem


func _ready() -> void:
	GameState.inventory.changed.connect(_refresh)
	GameState.hotbar_changed.connect(func(_index: int) -> void: _refresh())
	_build_slots()
	_refresh()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		inventory_panel.visible = not inventory_panel.visible
		get_viewport().set_input_as_handled()
	for index: int in range(8):
		if event.is_action_pressed("hotbar_%d" % (index + 1)):
			GameState.select_hotbar(index)
			get_viewport().set_input_as_handled()


func _build_slots() -> void:
	for index: int in range(24):
		var button := Button.new()
		button.custom_minimum_size = Vector2(58, 34)
		button.pressed.connect(_on_inventory_slot_pressed.bind(index))
		inventory_grid.add_child(button)
	for index: int in range(8):
		var button := Button.new()
		button.custom_minimum_size = Vector2(60, 30)
		button.pressed.connect(GameState.select_hotbar.bind(index))
		hotbar.add_child(button)


func _refresh() -> void:
	for index: int in range(24):
		_update_button(inventory_grid.get_child(index) as Button, index, false)
	for index: int in range(8):
		_update_button(hotbar.get_child(index) as Button, index, index == GameState.selected_hotbar)
	var selected_id := GameState.selected_item_id()
	selected_label.text = "Empty hand" if selected_id == &"" else GameState.get_item(selected_id).display_name


func _update_button(button: Button, index: int, selected: bool) -> void:
	var slot: Dictionary = GameState.inventory.slots[index]
	if slot["item_id"] == &"":
		button.text = "%d\n—" % (index + 1)
		button.modulate = Color.WHITE
	else:
		var item: ItemData = GameState.get_item(slot["item_id"])
		button.text = "%d\n%s ×%d" % [index + 1, item.display_name, slot["quantity"]]
		button.modulate = item.placeholder_color.lightened(0.25)
	button.add_theme_color_override("font_color", Color("#fff0b0") if selected else Color("#f2e6bc"))
	button.add_theme_font_size_override("font_size", 8)


func _on_inventory_slot_pressed(index: int) -> void:
	if index < 8:
		GameState.select_hotbar(index)
	else:
		GameState.inventory.move_slot(index, GameState.selected_hotbar)
