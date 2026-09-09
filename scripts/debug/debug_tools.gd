class_name DebugTools
extends CanvasLayer

var panel: PanelContainer


func _ready() -> void:
	add_to_group("debug_tools")
	_build_ui()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_toggle"):
		panel.visible = not panel.visible
		get_viewport().set_input_as_handled()


func _build_ui() -> void:
	layer = 70
	panel = PanelContainer.new(); panel.position = Vector2(220, 38); panel.custom_minimum_size = Vector2(200, 265); panel.visible = false; add_child(panel)
	var list := VBoxContainer.new(); panel.add_child(list)
	var title := Label.new(); title.text = "DEVELOPER TOOLS [F3]"; title.add_theme_font_size_override("font_size", 10); list.add_child(title)
	_add_button(list, "Advance Day", func() -> void: TimeManager.advance_day())
	_add_button(list, "Give Materials", give_materials)
	_add_button(list, "Give 30 XP", func() -> void: GameState.player_stats.add_experience(30))
	_add_button(list, "Heal / Restore", func() -> void: GameState.player_stats.restore_all())
	_add_button(list, "Spawn Slime", spawn_slime)
	_add_button(list, "Unlock Skills", unlock_skills)
	_add_button(list, "Give 100 Gold", func() -> void: GameState.add_gold(100))
	_add_button(list, "Toggle Combat Guides", toggle_guides)
	_add_button(list, "New Game", func() -> void: SaveManager.new_game())


func _add_button(parent: VBoxContainer, label: String, action: Callable) -> void:
	var button := Button.new(); button.text = label; button.add_theme_font_size_override("font_size", 8); button.pressed.connect(action); parent.add_child(button)


func give_materials() -> void:
	for id: StringName in [&"wood", &"stone", &"fiber", &"turnip_seed"]:
		GameState.inventory.add_item(GameState.get_item(id), 10)
	GameState.notify("Developer materials added")


func spawn_slime() -> void:
	var scene: PackedScene = load("res://scenes/monsters/monster.tscn")
	var monster: Monster = scene.instantiate(); monster.data = load("res://resources/monsters/slime.tres")
	var player := get_tree().get_first_node_in_group("player") as PlayerController
	get_tree().current_scene.add_child(monster); monster.global_position = player.global_position + Vector2(42, 0)


func unlock_skills() -> void:
	GameState.unlocked_skills["dash"] = true; GameState.unlocked_skills["power_slash"] = true; GameState.unlocked_skills["healing_pulse"] = true
	GameState.notify("All prototype skills unlocked")


func toggle_guides() -> void:
	var player := get_tree().get_first_node_in_group("player") as PlayerController
	var overlays := get_tree().get_nodes_in_group("combat_debug_overlay")
	var enabled := overlays.is_empty() or not (overlays[0] as CombatDebugOverlay).visible
	var tools := player.get_node("ToolController") as ToolController; tools.show_target = enabled
	for overlay: CombatDebugOverlay in overlays: overlay.set_enabled(enabled)
	GameState.notify("Combat guides %s" % ("on" if enabled else "off"))
