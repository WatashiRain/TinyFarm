class_name TalentTreeMenu
extends CanvasLayer

var panel_root: Control
var points_label: Label
var details_label: Label
var graph: TalentTreeGraph
var _was_tree_paused := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 80
	_build_ui()
	TalentManager.points_changed.connect(_on_points_changed)
	_on_points_changed(TalentManager.available_points(), TalentManager.earned_points, TalentManager.spent_points)
	visible = false


func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("talent_menu"):
		if visible:
			close_menu()
		else:
			open_menu()
		get_viewport().set_input_as_handled()
	elif visible and event.is_action_pressed("ui_cancel"):
		close_menu()
		get_viewport().set_input_as_handled()


func open_menu() -> void:
	if visible:
		return
	_was_tree_paused = get_tree().paused
	visible = true
	get_tree().paused = true
	graph.refresh()
	details_label.text = "Hover or focus a talent to inspect it. Click an available node to spend Talent Points."


func close_menu() -> void:
	if not visible:
		return
	visible = false
	get_tree().paused = _was_tree_paused


func _build_ui() -> void:
	panel_root = ColorRect.new()
	panel_root.color = Color(0.035, 0.055, 0.07, 0.94)
	panel_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(panel_root)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel_root.add_child(margin)
	var panel := PanelContainer.new()
	margin.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 3)
	panel.add_child(content)
	var header := HBoxContainer.new()
	content.add_child(header)
	var title := Label.new()
	title.text = "CHUN'S TALENT TREE"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size", 14)
	header.add_child(title)
	points_label = Label.new()
	points_label.add_theme_color_override("font_color", Color("#ffe08a"))
	header.add_child(points_label)
	var close_button := Button.new()
	close_button.text = "Close [T / Esc]"
	close_button.add_theme_font_size_override("font_size", 8)
	close_button.pressed.connect(close_menu)
	header.add_child(close_button)
	graph = TalentTreeGraph.new()
	graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	graph.talent_hovered.connect(_show_talent_details)
	content.add_child(graph)
	details_label = Label.new()
	details_label.custom_minimum_size = Vector2(0, 50)
	details_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details_label.add_theme_font_size_override("font_size", 8)
	details_label.add_theme_color_override("font_color", Color("#f3e7bf"))
	content.add_child(details_label)
	var footer := Label.new()
	footer.text = "Red: Vitality   Green: Agility   Blue: Mana   Cyan: Mana Flow   Bright: purchased   Gray: locked"
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_font_size_override("font_size", 7)
	footer.add_theme_color_override("font_color", Color("#aab4bd"))
	content.add_child(footer)


func _show_talent_details(talent: TalentData) -> void:
	var rejection := TalentManager.purchase_rejection_reason(talent.id)
	var state_text := "AVAILABLE" if rejection.is_empty() else rejection
	if TalentManager.get_rank(talent.id) >= talent.max_rank:
		state_text = "PURCHASED — MAX RANK"
	details_label.text = "%s — %s\n%s\nRank %d/%d   Cost %d TP   Required level %d" % [talent.display_name, state_text, talent.description, TalentManager.get_rank(talent.id), talent.max_rank, talent.cost_per_rank, talent.required_level]


func _on_points_changed(available: int, earned: int, spent: int) -> void:
	if points_label != null:
		points_label.text = "TP %d  (earned %d / spent %d)   " % [available, earned, spent]
